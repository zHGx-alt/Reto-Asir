#!/usr/bin/env bash
# Tarea 33 · Instala Docker y despliega Odoo + PostgreSQL en un Debian 13 sin escritorio.
#
# Uso (desde la carpeta que contiene docker-compose.yml):
#   sudo ./desplegar-odoo.sh
# Se puede ejecutar varias veces: no regenera contraseñas ni vuelve a crear la base de datos si ya existen.
set -euo pipefail

DESTINO=/opt/odoo
ORIGEN="$(cd "$(dirname "$0")" && pwd)"

log() { printf '\n==> %s\n' "$*"; }
aleatoria() { openssl rand -base64 24 | tr -d '/+=' | cut -c1-24; }

[[ $EUID -eq 0 ]] || { echo "Ejecuta el script con sudo: sudo $0" >&2; exit 1; }

log "1/6 Instalando Docker (paquetes oficiales de Debian)"
DEBIAN_FRONTEND=noninteractive apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
  docker.io docker-cli docker-compose openssl curl ca-certificates >/dev/null
systemctl enable --now docker
docker --version
docker compose version

log "2/6 Copiando el proyecto a ${DESTINO} (solo root puede leerlo)"
install -d -m 750 "$DESTINO" "$DESTINO/config"
install -m 644 "$ORIGEN/docker-compose.yml" "$DESTINO/docker-compose.yml"
cd "$DESTINO"

log "3/6 Generando secretos (solo la primera vez)"
if [[ ! -f .env ]]; then
  umask 077
  cat > .env <<EOF
ODOO_VERSION=19.0
POSTGRES_USER=odoo
POSTGRES_PASSWORD=$(aleatoria)
ODOO_DB=tienda
ODOO_ADMIN_PASSWORD=$(aleatoria)
ODOO_MASTER_PASSWORD=$(aleatoria)
EOF
  umask 022
  echo "  .env creado (permisos 600)"
else
  echo "  .env ya existe: se mantiene"
fi
chmod 600 .env
set -a; source .env; set +a

if [[ ! -f config/odoo.conf ]]; then
  cat > config/odoo.conf <<EOF
[options]
; Contraseña maestra (gestión de bases de datos). Generada al azar.
admin_passwd = ${ODOO_MASTER_PASSWORD}
; Seguridad: sin listado ni gestor web de bases de datos, y solo la base de la tienda
list_db = False
dbfilter = ^${ODOO_DB}\$
data_dir = /var/lib/odoo
; Modo multihilo (workers = 0): suficiente para una tienda pequeña y no necesita proxy para el chat/avisos en tiempo real.
; Con más usuarios: workers = 2 y un proxy inverso que envíe /websocket al puerto 8072.
workers = 0
EOF
  echo "  config/odoo.conf creado"
fi
# El contenedor lee el fichero como usuario "odoo"; la carpeta /opt/odoo (750, root) impide que lo lean otros usuarios del sistema
chmod 644 config/odoo.conf

log "4/6 Descargando imágenes y arrancando PostgreSQL"
docker compose pull -q
docker compose up -d db
until [[ "$(docker inspect -f '{{.State.Health.Status}}' "$(docker compose ps -q db)")" == healthy ]]; do sleep 2; done
echo "  PostgreSQL listo"

log "5/6 Creando la base de datos '${ODOO_DB}' (español, sin datos de demostración)"
if docker compose exec -T db psql -U "$POSTGRES_USER" -d postgres -tAc \
     "SELECT 1 FROM pg_database WHERE datname='${ODOO_DB}'" | grep -q 1; then
  echo "  La base de datos ya existe: se mantiene"
else
  docker compose run --rm -T odoo -d "$ODOO_DB" -i base --without-demo=all \
    --load-language=es_ES --stop-after-init --no-http
  # Cambiar la contraseña por defecto del usuario admin (admin/admin) por la del .env
  docker compose run --rm -T odoo odoo shell -d "$ODOO_DB" --no-http <<EOF
admin = env.ref('base.user_admin')
admin.write({'password': '${ODOO_ADMIN_PASSWORD}', 'lang': 'es_ES', 'tz': 'Europe/Madrid'})
env.cr.commit()
print('Contraseña de admin cambiada')
EOF
fi

log "6/6 Arrancando Odoo"
docker compose up -d odoo
for _ in $(seq 1 90); do
  curl -fsS -o /dev/null http://127.0.0.1:8069/web/login && break
  sleep 2
done
docker compose ps
echo
if curl -fsS -o /dev/null http://127.0.0.1:8069/web/login; then
  echo "Odoo funcionando en http://<IP-del-servidor>:8069  ·  base de datos: ${ODOO_DB}  ·  usuario: admin"
  echo "La contraseña de admin está en ${DESTINO}/.env (ODOO_ADMIN_PASSWORD):  sudo grep ODOO_ADMIN ${DESTINO}/.env"
else
  echo "Odoo no responde todavía. Revisa:  sudo docker compose -f ${DESTINO}/docker-compose.yml logs odoo" >&2
  exit 1
fi
