#!/usr/bin/env bash
# Tarea 33 · Cortafuegos del servidor (ufw). Parte de la decisión de red de la tarea 23 (apartado 5.2):
# en la red plana, TPV, gerente y servidor comparten red, así que el servidor tiene que protegerse solo.
#
#   Entrada bloqueada por defecto; salida permitida (actualizaciones, imágenes de Docker, copias).
#   SSH (22)           solo desde el PC del gerente.
#   HTTP/HTTPS (80/443) solo desde la LAN del personal (Odoo detrás del proxy, tarea 52).
#
# Uso:  sudo ./cortafuegos-servidor.sh
#       sudo LAN=192.168.10.0/24 GERENTE=192.168.10.20 ./cortafuegos-servidor.sh   (valores por defecto)
# Si se ejecuta por SSH desde otra IP (por ejemplo, la VM con NAT de VirtualBox), esa IP también se
# permite y se avisa, para no quedarse fuera. Idempotente.
#
# Ojo con Docker: los puertos que publica un contenedor (80 y 443 del proxy) los abre Docker en iptables
# por delante de ufw. Por eso el proxy publica 80/443 (que se quieren abiertos) y Odoo solo 127.0.0.1:8069.
set -euo pipefail

LAN=${LAN:-192.168.10.0/24}
GERENTE=${GERENTE:-192.168.10.20}
log() { printf '\n==> %s\n' "$*"; }

[[ $EUID -eq 0 ]] || { echo "Ejecuta el script con sudo: sudo $0" >&2; exit 1; }

log "1/3 Instalando ufw"
command -v ufw >/dev/null || DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ufw >/dev/null
ufw --version | head -1

log "2/3 Reglas"
ufw --force reset >/dev/null
ufw default deny incoming
ufw default allow outgoing
ufw allow from "$GERENTE" to any port 22 proto tcp comment 'SSH solo desde el PC del gerente'
# Quien ejecuta el script por SSH desde otra IP no se queda fuera
ssh_origen=${SSH_CLIENT:-}
ssh_origen=${ssh_origen%% *}
# sudo no conserva SSH_CLIENT: se busca en los procesos padre (el shell de la sesión SSH lo tiene).
# "who -m" no sirve con "ssh host 'sudo ...'": sin shell de login no hay entrada en utmp (corregido el 30/10)
pid=$$
while [[ -z $ssh_origen && $pid -gt 1 ]]; do
  ssh_origen=$( { tr '\0' '\n' < "/proc/$pid/environ"; } 2>/dev/null | sed -n 's/^SSH_CLIENT=\([^ ]*\) .*/\1/p' || true)
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ' || true)
  [[ -n $pid ]] || pid=1
done
[[ -n $ssh_origen ]] || ssh_origen=$(who -m 2>/dev/null | sed -n 's/.*(\([0-9.]*\)).*/\1/p')
if [[ -n $ssh_origen && $ssh_origen != "$GERENTE" ]]; then
  ufw allow from "$ssh_origen" to any port 22 proto tcp comment 'SSH de quien configuró el cortafuegos'
  echo "  AVISO: también se permite SSH desde $ssh_origen (la conexión actual). Quitarlo al acabar:"
  echo "         sudo ufw delete allow from $ssh_origen to any port 22 proto tcp"
fi
ufw allow from "$LAN" to any port 80,443 proto tcp comment 'Odoo por HTTPS desde la LAN (tarea 52)'

log "3/3 Activando"
ufw --force enable
ufw status verbose
