#!/usr/bin/env bash
# Tareas 45 y 48 · Recuperar el servidor en una máquina NUEVA a partir del disco USB de copias (RTO real).
#
# Es el plan de desastre de la tarea 48 (sección 11) hecho script: el servidor se ha perdido, hay una
# máquina recién instalada con el preseed de la tarea 33 y el USB BACKUP_USB conectado. No hay Docker,
# ni imágenes, ni /opt/odoo: todo sale de la copia.
#
# Uso:  sudo ./recuperar-servidor-nuevo.sh FICHERO_CONTRASEÑA
#   FICHERO_CONTRASEÑA: la contraseña de restic sacada de KeePassXC y pegada en un fichero temporal
#   (permisos 600). El script la copia a /root/.config/backup-odoo/restic.pass, donde la espera la copia
#   nocturna (tarea 44), y borra el fichero temporal.
#
# Al acabar, Odoo funciona con los datos de la copia (HTTPS si la copia lleva la tarea 52) y escribe el
# tiempo total. El cronómetro de verdad empieza antes: al crear la máquina (ver tarea 45, sección 6).
set -euo pipefail

PASS_TEMP=${1:?Uso: sudo $0 FICHERO_CONTRASEÑA (la de restic, sacada de KeePassXC)}
[[ $EUID -eq 0 ]] || { echo "Ejecuta con sudo" >&2; exit 1; }
[[ -r $PASS_TEMP ]] || { echo "No puedo leer $PASS_TEMP" >&2; exit 1; }

export RESTIC_PASSWORD_FILE=/root/.config/backup-odoo/restic.pass
export RESTIC_CACHE_DIR=/var/cache/restic
RESTAURADO=/srv/restaurado
T0=$(date +%s)
log() { printf '\n==> [%s] (+%ss) %s\n' "$(date +%T)" "$(( $(date +%s) - T0 ))" "$*"; }

log "1/7 Herramientas: restic, Docker y Compose"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq restic docker.io docker-compose curl >/dev/null
docker compose version

log "2/7 Contraseña de restic y disco USB"
install -d -m 700 /root/.config/backup-odoo
install -m 600 "$PASS_TEMP" "$RESTIC_PASSWORD_FILE"
shred -u "$PASS_TEMP" 2>/dev/null || rm -f "$PASS_TEMP"
DISCO=$(blkid -L BACKUP_USB) || { echo "ERROR: conecta el disco USB BACKUP_USB" >&2; exit 1; }
install -d /mnt/usb-backup
mountpoint -q /mnt/usb-backup || mount -o ro "$DISCO" /mnt/usb-backup
# --no-lock: el USB se monta en solo lectura para no tocar la copia, y restic no puede dejar su bloqueo en él
restic -r /mnt/usb-backup/restic snapshots --no-lock --tag odoo --latest 1 --compact

log "3/7 Restaurar la última instantánea"
install -d -m 700 "$RESTAURADO"
restic -r /mnt/usb-backup/restic restore --no-lock latest --tag odoo --target "$RESTAURADO" | tail -1
TEMP="$RESTAURADO/srv/datos/temp-backup"
ADJUNTOS=$(find "$RESTAURADO" -path '*/volumes/odoo_odoo-web-data/_data' -type d | head -1)
[[ -n $ADJUNTOS ]] || { echo "ERROR: la copia no lleva los adjuntos de Odoo" >&2; exit 1; }
cp -a "$RESTAURADO/opt/odoo" /opt/odoo
cd /opt/odoo
set -a; source .env; set +a
echo "  /opt/odoo: $(ls -A | tr '\n' ' ')"

log "4/7 PostgreSQL y bases de datos (${ODOO_DB} y almi_chain)"
docker compose up -d db
until docker compose exec -T db pg_isready -U "$POSTGRES_USER" -d postgres -q 2>/dev/null; do sleep 1; done
sleep 2
# Roles de la tarea 42 (rol_aplicacion, rol_lectura...). El del administrador ya existe: ese error es esperado.
docker compose exec -T db psql -q -U "$POSTGRES_USER" -d postgres < "$TEMP/globals.sql" >/dev/null 2>&1 || true
docker compose exec -T db createdb -U "$POSTGRES_USER" "$ODOO_DB"
docker compose exec -T db pg_restore -U "$POSTGRES_USER" -d "$ODOO_DB" --no-owner --exit-on-error < "$TEMP/${ODOO_DB}.dump"
if [[ -f $TEMP/almi_chain.dump ]]; then
  docker compose exec -T db createdb -U "$POSTGRES_USER" almi_chain
  docker compose exec -T db pg_restore -U "$POSTGRES_USER" -d almi_chain --no-owner --exit-on-error < "$TEMP/almi_chain.dump"
fi

log "5/7 Adjuntos de Odoo (filestore)"
docker volume create odoo_odoo-web-data >/dev/null
VOL=$(docker volume inspect -f '{{.Mountpoint}}' odoo_odoo-web-data)
cp -a "$ADJUNTOS/." "$VOL/"
chown -R 100:101 "$VOL"
echo "  $(find "$VOL/filestore/$ODOO_DB" -type f | wc -l) ficheros"

log "6/7 Arrancar Odoo (y el proxy HTTPS si la copia lo lleva)"
docker compose up -d
docker compose ps --format '  {{.Name}} {{.Image}} {{.Status}}'
for _ in $(seq 1 90); do curl -fs -o /dev/null http://127.0.0.1:8069/web/login && break; sleep 2; done

log "7/7 Comprobaciones"
sql() { docker compose exec -T db psql -U "$POSTGRES_USER" -d "$1" -tAc "$2" </dev/null; }
HTTP=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8069/web/login)
HTTPS=$(curl -sk -o /dev/null -w '%{http_code}' https://127.0.0.1/web/login || true)
LOGIN=$(curl -s -H 'Content-Type: application/json' http://127.0.0.1:8069/jsonrpc \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"call\",\"params\":{\"service\":\"common\",\"method\":\"login\",\"args\":[\"$ODOO_DB\",\"admin\",\"$ODOO_ADMIN_PASSWORD\"]}}" \
  | grep -o '"result": *[0-9a-z]*' | grep -o '[0-9a-z]*$' || true)
echo "  Odoo /web/login por HTTP (solo el propio servidor): $HTTP"
echo "  Odoo /web/login por HTTPS (proxy de la tarea 52): ${HTTPS:-sin proxy}"
echo "  Login de admin (uid): ${LOGIN:-FALLA}"
echo "  Puntos de venta: $(sql "$ODOO_DB" "SELECT string_agg(name, ', ' ORDER BY id) FROM pos_config")"
echo "  Cajeros activos: $(sql "$ODOO_DB" "SELECT string_agg(login, ', ' ORDER BY id) FROM res_users WHERE active AND login LIKE 'cajero%'")"
echo "  Última venta del TPV: $(sql "$ODOO_DB" "SELECT name || ' · ' || date_order || ' · ' || amount_total || ' €' FROM pos_order ORDER BY id DESC LIMIT 1")"
echo "  Ventas del TPV: $(sql "$ODOO_DB" "SELECT count(*) FROM pos_order") · clientes: $(sql "$ODOO_DB" "SELECT count(*) FROM res_partner") · productos: $(sql "$ODOO_DB" "SELECT count(*) FROM product_template")"
if [[ -f $TEMP/almi_chain.dump ]]; then
  echo "  almi_chain: $(sql almi_chain "SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'") tablas, $(sql almi_chain "SELECT count(*) FROM factura") facturas"
fi
echo "  Antigüedad de la copia (RPO): $(( ( $(date +%s) - $(stat -c %Y "$TEMP/${ODOO_DB}.dump") ) / 3600 )) h"
umount /mnt/usb-backup
echo
echo "  Tiempo de este script: $(( $(date +%s) - T0 )) s"
[[ $HTTP == 200 && $LOGIN == 2 ]] || { echo "  ❌ Odoo no responde o no deja entrar"; exit 1; }
echo "  ✅ Servidor recuperado. Falta: la copia nocturna (instalar-backup.sh de la tarea 44) y el cortafuegos (tarea 33)."
