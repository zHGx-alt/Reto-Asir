#!/usr/bin/env bash
# Tarea 45 · Prueba de restauración de la copia de seguridad de Odoo (tarea 44), con evidencias.
#
# Restaura la última copia en un ENTORNO AISLADO, sin tocar producción:
#   - PostgreSQL y Odoo temporales en una red Docker propia ("restauracion"), que el Odoo de producción no ve
#     (si se restaurase en el PostgreSQL de producción, el programador de tareas del Odoo de producción
#      se conectaría también a la copia)
#   - el Odoo de prueba solo escucha en 127.0.0.1:8070 del servidor
# Compara lo restaurado con lo original (Odoo y la BD propia almi_chain), entra en el Odoo restaurado
# y al final lo borra todo.
#
# Uso:  sudo ./probar-restauracion.sh [usb|raid|s3]  (por defecto usb: la copia que está fuera del local;
#       s3 lee las claves de /root/.config/backup-odoo/s3.env, como backup-odoo.sh)
set -euo pipefail

ORIGEN=${1:-usb}
export RESTIC_PASSWORD_FILE=/root/.config/backup-odoo/restic.pass
export RESTIC_CACHE_DIR=/var/cache/restic
COMPOSE=(docker compose -f /opt/odoo/docker-compose.yml)
DESTINO=/srv/datos/prueba-restauracion
RED=restauracion
PG=pg-prueba-restauracion
ODOO=odoo-prueba-restauracion

set -a; source /opt/odoo/.env; set +a
log() { printf '\n==> [%s] %s\n' "$(date +%T)" "$*"; }
# </dev/null: si no, "docker compose exec" se come la entrada estándar del bucle que lee las comprobaciones
sql_prod()   { "${COMPOSE[@]}" exec -T db psql -U "$POSTGRES_USER" -d "$ODOO_DB" -tAc "$1" </dev/null; }
sql_prueba() { docker exec "$PG" psql -U "$POSTGRES_USER" -d "$ODOO_DB" -tAc "$1" </dev/null; }
# Lo mismo contra la BD propia de la tarea 40 (almi_chain)
sql_prod_bd()   { "${COMPOSE[@]}" exec -T db psql -U "$POSTGRES_USER" -d almi_chain -tAc "$1" </dev/null; }
sql_prueba_bd() { docker exec "$PG" psql -U "$POSTGRES_USER" -d almi_chain -tAc "$1" </dev/null; }

limpiar() {
  docker rm -f "$ODOO" "$PG" >/dev/null 2>&1 || true
  docker network rm "$RED" >/dev/null 2>&1 || true
  rm -rf "$DESTINO"
  if mountpoint -q /mnt/usb-backup; then umount /mnt/usb-backup; fi
}
trap limpiar EXIT

[[ $EUID -eq 0 ]] || { echo "Ejecuta con sudo" >&2; exit 1; }
limpiar   # por si quedó algo de una prueba anterior
T0=$(date +%s)

log "1/6 Elegir la copia ($ORIGEN)"
if [[ $ORIGEN == usb ]]; then
  blkid -L BACKUP_USB >/dev/null || { echo "ERROR: conecta el disco USB BACKUP_USB" >&2; exit 1; }
  mount /mnt/usb-backup
  REPO=/mnt/usb-backup/restic
elif [[ $ORIGEN == s3 ]]; then
  [[ -r /root/.config/backup-odoo/s3.env ]] || { echo "ERROR: falta /root/.config/backup-odoo/s3.env" >&2; exit 1; }
  set -a; source /root/.config/backup-odoo/s3.env; set +a
  REPO=$REPO_S3
else
  REPO=/srv/datos/restic
fi
restic -r "$REPO" snapshots --tag odoo --latest 1 --compact

log "2/6 Restaurar los ficheros de la última instantánea"
install -d -m 700 "$DESTINO"
restic -r "$REPO" restore latest --tag odoo --target "$DESTINO" | tail -1
DUMP="$DESTINO/srv/datos/temp-backup/${ODOO_DB}.dump"
ADJUNTOS="$DESTINO/var/lib/docker/volumes/odoo_odoo-web-data/_data"
echo "  Volcado: $(du -h "$DUMP" | cut -f1) · adjuntos: $(find "$ADJUNTOS" -type f | wc -l) ficheros · configuración: $(ls -A "$DESTINO/opt/odoo" | tr '\n' ' ')"

log "3/6 PostgreSQL aislado y restauración de la base de datos"
docker network create --internal "$RED" >/dev/null
docker run -d --name "$PG" --network "$RED" \
  -e POSTGRES_USER="$POSTGRES_USER" -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" -e POSTGRES_DB=postgres \
  postgres:17 >/dev/null
until docker exec "$PG" pg_isready -U "$POSTGRES_USER" -d postgres -q 2>/dev/null; do sleep 1; done
sleep 2
docker exec "$PG" createdb -U "$POSTGRES_USER" "$ODOO_DB"
docker exec -i "$PG" pg_restore -U "$POSTGRES_USER" -d "$ODOO_DB" --no-owner --exit-on-error < "$DUMP"
echo "  Base '$ODOO_DB' restaurada en el PostgreSQL aislado ($PG, red interna '$RED')"
DUMP_BD="$DESTINO/srv/datos/temp-backup/almi_chain.dump"
HAY_BD=0
if [[ -f $DUMP_BD ]]; then
  HAY_BD=1
  # Primero los roles (globals.sql): sin rol_aplicacion y rol_lectura, los permisos de la tarea 42 no se restauran.
  # El rol del administrador ya existe en el contenedor: ese error es esperado y se ignora.
  docker exec -i "$PG" psql -q -U "$POSTGRES_USER" -d postgres < "$DESTINO/srv/datos/temp-backup/globals.sql" >/dev/null 2>&1 || true
  docker exec "$PG" createdb -U "$POSTGRES_USER" almi_chain
  docker exec -i "$PG" pg_restore -U "$POSTGRES_USER" -d almi_chain --no-owner --exit-on-error < "$DUMP_BD"
  echo "  Base 'almi_chain' (tarea 40) restaurada con sus roles y permisos"
fi

log "4/6 Comparar: producción vs restaurado"
printf '  %-36s %-34s %-34s %s\n' "Dato" "Producción" "Restaurado" ""
FALLOS=0
comparar() {
  local nombre=$1 a=$2 b=$3 marca
  if [[ $a == "$b" ]]; then marca="OK"; else marca="DISTINTO"; FALLOS=$((FALLOS+1)); fi
  printf '  %-36s %-34s %-34s %s\n' "$nombre" "$a" "$b" "$marca"
}
while IFS='|' read -r nombre sql; do
  comparar "$nombre" "$(sql_prod "$sql")" "$(sql_prueba "$sql")"
done <<'EOF'
Clientes y contactos|SELECT count(*) FROM res_partner
Productos|SELECT count(*) FROM product_template
Pedidos de venta|SELECT count(*) FROM sale_order
Facturas validadas|SELECT count(*) FROM account_move WHERE move_type='out_invoice' AND state='posted'
Total facturado (€)|SELECT coalesce(sum(amount_total),0) FROM account_move WHERE move_type='out_invoice' AND state='posted'
Última factura|SELECT max(name) FROM account_move WHERE move_type='out_invoice' AND state='posted'
Apuntes contables|SELECT count(*) FROM account_move_line
Puntos de venta|SELECT string_agg(name, ',' ORDER BY id) FROM pos_config
Usuarios activos|SELECT string_agg(login, ',' ORDER BY id) FROM res_users WHERE active
EOF
ORIG_FS="/var/lib/docker/volumes/odoo_odoo-web-data/_data/filestore/$ODOO_DB"
REST_FS="$ADJUNTOS/filestore/$ODOO_DB"
huella_carpeta() { (cd "$1" && find . -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -c1-16); }
comparar "Adjuntos: nº de ficheros" "$(find "$ORIG_FS" -type f | wc -l)" "$(find "$REST_FS" -type f | wc -l)"
comparar "Adjuntos: huella del contenido" "$(huella_carpeta "$ORIG_FS")" "$(huella_carpeta "$REST_FS")"
if [[ $HAY_BD -eq 1 ]]; then
  while IFS='|' read -r nombre sql; do
    comparar "$nombre" "$(sql_prod_bd "$sql")" "$(sql_prueba_bd "$sql")"
  done <<'EOF'
almi_chain: tablas|SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'
almi_chain: filas por tabla (huella)|SELECT md5(string_agg(relname || '=' || n, ',' ORDER BY relname)) FROM (SELECT relname, (xpath('/row/c/text()', query_to_xml('SELECT count(*) AS c FROM public.' || quote_ident(relname), false, true, '')))[1]::text AS n FROM pg_stat_user_tables) t
almi_chain: clientes|SELECT count(*) FROM cliente
almi_chain: platos en carta|SELECT count(*) FROM plato
almi_chain: facturas|SELECT count(*) FROM factura
almi_chain: total de líneas (€)|SELECT coalesce(sum(cantidad * precio_unitario),0) FROM linea_factura
almi_chain: permisos de rol_aplicacion y rol_lectura|SELECT count(*) FROM information_schema.role_table_grants WHERE grantee IN ('rol_aplicacion','rol_lectura')
EOF
else
  echo "  (la copia no lleva almi_chain: no se compara la BD propia)"
fi
for f in docker-compose.yml .env config/odoo.conf; do
  comparar "Config: $f" "$(sha256sum < "/opt/odoo/$f" | cut -c1-16)" "$(sha256sum < "$DESTINO/opt/odoo/$f" | cut -c1-16)"
done

log "5/6 Arrancar un Odoo de prueba con lo restaurado y entrar"
install -d "$DESTINO/odoo-data/filestore"
cp -a "$REST_FS" "$DESTINO/odoo-data/filestore/$ODOO_DB"
chown -R 100:101 "$DESTINO/odoo-data"
# La red "restauracion" es interna (sin salida). Para publicar 127.0.0.1:8070 se conecta además a la red bridge.
# Sin tareas programadas (--max-cron-threads=0): la copia no envía correos ni hace nada por su cuenta.
docker create --name "$ODOO" --network "$RED" -p 127.0.0.1:8070:8069 \
  -v "$DESTINO/odoo-data:/var/lib/odoo" \
  -e HOST="$PG" -e USER="$POSTGRES_USER" -e PASSWORD="$POSTGRES_PASSWORD" \
  "odoo:${ODOO_VERSION}" -- --db-filter="^${ODOO_DB}\$" -d "$ODOO_DB" --no-database-list --max-cron-threads=0 >/dev/null
docker network connect bridge "$ODOO"
docker start "$ODOO" >/dev/null
for _ in $(seq 1 60); do curl -fs -o /dev/null http://127.0.0.1:8070/web/login && break; sleep 2; done
HTTP=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8070/web/login)
LOGIN=$(curl -s -H 'Content-Type: application/json' http://127.0.0.1:8070/jsonrpc \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"call\",\"params\":{\"service\":\"common\",\"method\":\"login\",\"args\":[\"$ODOO_DB\",\"admin\",\"$ODOO_ADMIN_PASSWORD\"]}}" \
  | grep -o '"result": *[0-9a-z]*' | grep -o '[0-9a-z]*$' || true)
comparar "Odoo restaurado: /web/login" "200" "$HTTP"
comparar "Odoo restaurado: login admin (uid)" "2" "$LOGIN"
echo "  Conexiones a PostgreSQL de producción desde fuera de producción: $(sql_prod "SELECT count(*) FROM pg_stat_activity WHERE datname<>'$ODOO_DB' AND datname IS NOT NULL AND datname<>'postgres'")"

log "6/6 Resultado"
echo "  Tiempo total de recuperación (RTO medido): $(( $(date +%s) - T0 )) s"
echo "  Antigüedad de la copia restaurada (RPO): $(( ( $(date +%s) - $(stat -c %Y "$DUMP") ) / 60 )) min"
if [[ $FALLOS -eq 0 ]]; then
  echo "  ✅ RESTAURACIÓN CORRECTA: todo coincide y el Odoo restaurado funciona"
else
  echo "  ❌ $FALLOS comprobaciones fallidas"; exit 1
fi
echo "  (limpiando: se borran el PostgreSQL y el Odoo temporales, su red y los ficheros restaurados)"
