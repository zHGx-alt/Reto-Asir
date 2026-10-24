#!/usr/bin/env bash
# Tarea 52 · Pone Odoo detrás de un proxy HTTPS (nginx) en el servidor de la tarea 33.
#
#   1. Genera un certificado propio para la IP del servidor (válido 825 días; la CA es el propio servidor).
#   2. Copia nginx.conf y docker-compose.https.yml a /opt/odoo.
#   3. Activa proxy_mode en odoo.conf (Odoo confía en las cabeceras X-Forwarded-* del proxy).
#   4. Fija COMPOSE_FILE en /opt/odoo/.env para que cualquier "docker compose up" incluya el proxy.
#   5. Levanta el proxy; Odoo deja de escuchar en la LAN (solo 127.0.0.1:8069).
#
# Uso (desde la carpeta de este script):  sudo ./activar-https.sh [IP_DEL_SERVIDOR]
# Idempotente: si el certificado existe, no se regenera (los TPV ya lo tienen instalado).
set -euo pipefail

IP=${1:-192.168.10.10}
DIR=/opt/odoo
ORIGEN=$(cd "$(dirname "$0")" && pwd)
log() { printf '\n==> %s\n' "$*"; }

[[ $EUID -eq 0 ]] || { echo "Ejecuta el script con sudo: sudo $0" >&2; exit 1; }
[[ -f $DIR/docker-compose.yml ]] || { echo "No está $DIR/docker-compose.yml: primero la tarea 33 (desplegar-odoo.sh)" >&2; exit 1; }
docker compose version --short | awk -F. '{ exit !($1 > 2 || ($1 == 2 && $2 >= 24)) }' \
  || { echo "Hace falta Docker Compose 2.24 o posterior (por '!override')" >&2; exit 1; }

log "1/5 Certificado para $IP"
install -d -m 750 "$DIR/https/certs"
if [[ ! -f $DIR/https/certs/odoo.crt ]]; then
  openssl req -x509 -newkey rsa:2048 -sha256 -days 825 -nodes \
    -keyout "$DIR/https/certs/odoo.key" -out "$DIR/https/certs/odoo.crt" \
    -subj "/CN=Odoo Almi-Chain/O=Almi-Chain" \
    -addext "subjectAltName=IP:$IP,DNS:odoo.almichain.local" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,digitalSignature,keyEncipherment,keyCertSign" \
    -addext "extendedKeyUsage=serverAuth" 2>/dev/null
  chmod 640 "$DIR/https/certs/odoo.key"
  echo "  Creado. Huella SHA-256 (para comprobarla al instalarlo en los TPV):"
else
  echo "  Ya existe: se mantiene. Huella SHA-256:"
fi
openssl x509 -in "$DIR/https/certs/odoo.crt" -noout -fingerprint -sha256 | sed 's/^/  /'

log "2/5 Configuración de nginx y del proxy"
install -m 644 "$ORIGEN/nginx.conf" "$DIR/https/nginx.conf"
install -m 644 "$ORIGEN/docker-compose.https.yml" "$DIR/docker-compose.https.yml"

log "3/5 proxy_mode en odoo.conf"
if grep -q '^proxy_mode' "$DIR/config/odoo.conf"; then
  sed -i 's/^proxy_mode.*/proxy_mode = True/' "$DIR/config/odoo.conf"
else
  printf '; Detrás del proxy HTTPS (tarea 52)\nproxy_mode = True\n' >> "$DIR/config/odoo.conf"
fi
echo "  $(grep '^proxy_mode' "$DIR/config/odoo.conf")"

log "4/5 COMPOSE_FILE en .env"
sed -i '/^COMPOSE_FILE=/d' "$DIR/.env"
echo "COMPOSE_FILE=docker-compose.yml:docker-compose.https.yml" >> "$DIR/.env"

log "5/5 Levantando Odoo y el proxy"
cd "$DIR"
docker compose up -d --remove-orphans
sleep 5
docker compose ps

log "Comprobación"
echo "  HTTPS:      $(curl -sk -o /dev/null -w '%{http_code}' "https://$IP/web/login") (esperado 200)"
echo "  HTTP → 443: $(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' "http://$IP/web/login") (esperado 301)"
echo "  8069 en la LAN: $(curl -s -m 3 -o /dev/null -w '%{http_code}' "http://$IP:8069/web/login" || true) (esperado 000: cerrado)"
echo
echo "Listo. Falta instalar $DIR/https/certs/odoo.crt como raíz de confianza en los TPV y en el PC del gerente"
echo "(configurar-tpv.ps1 -CertificadoOdoo, tarea 13) y cambiar la URL del quiosco a https://$IP/pos/ui."
