#!/usr/bin/env bash
# Tarea 43 · Crea un RAID 1 (espejo) por software con mdadm y lo monta en /srv/datos
#
# Uso:  sudo ./crear-raid1.sh /dev/sdX /dev/sdY
# SEGURIDAD: solo continúa si los dos discos están completamente vacíos (sin particiones, sin sistema de archivos)
# y no son el disco del sistema. Si el RAID ya existe, no hace nada.
set -euo pipefail

MD=/dev/md0
MONTAJE=/srv/datos

[[ $EUID -eq 0 ]] || { echo "Ejecuta con sudo" >&2; exit 1; }
[[ $# -eq 2 ]] || { echo "Uso: sudo $0 /dev/sdX /dev/sdY" >&2; exit 1; }
DISCO1=$1; DISCO2=$2

log() { printf '\n==> %s\n' "$*"; }

log "1/5 Instalando mdadm"
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mdadm >/dev/null
mdadm --version

if [[ -e $MD ]] && mdadm --detail "$MD" >/dev/null 2>&1; then
  echo "El RAID $MD ya existe:"; mdadm --detail "$MD"; exit 0
fi

log "2/5 Comprobando que los discos están vacíos"
DISCO_SISTEMA=/dev/$(lsblk -no PKNAME "$(findmnt -no SOURCE /)")
for d in "$DISCO1" "$DISCO2"; do
  [[ -b $d ]] || { echo "ERROR: $d no existe" >&2; exit 1; }
  [[ $d != "$DISCO_SISTEMA" ]] || { echo "ERROR: $d es el disco del sistema" >&2; exit 1; }
  if [[ $(lsblk -no NAME "$d" | wc -l) -gt 1 ]] || [[ -n $(blkid -p "$d" 2>/dev/null) ]]; then
    echo "ERROR: $d tiene particiones o datos. No se toca." >&2; exit 1
  fi
  echo "  $d: vacío ($(lsblk -dno SIZE "$d"))"
done

log "3/5 Creando el RAID 1 en $MD"
mdadm --create "$MD" --level=1 --raid-devices=2 --metadata=1.2 --name=datos --run "$DISCO1" "$DISCO2"

log "4/5 Sistema de archivos ext4 y montaje en $MONTAJE"
mkfs.ext4 -q -L datos "$MD"
mkdir -p "$MONTAJE"
UUID=$(blkid -s UUID -o value "$MD")
grep -q "$UUID" /etc/fstab || echo "UUID=$UUID  $MONTAJE  ext4  defaults,nofail  0  2" >> /etc/fstab
systemctl daemon-reload
mount "$MONTAJE"

log "5/5 Haciendo el RAID persistente y vigilado"
# Que se monte solo al arrancar
mdadm --detail --scan | grep -q "$MD" && { grep -q "name=.*datos" /etc/mdadm/mdadm.conf || mdadm --detail --scan >> /etc/mdadm/mdadm.conf; }
sed -i 's/^#\?MAILADDR.*/MAILADDR root/' /etc/mdadm/mdadm.conf
update-initramfs -u >/dev/null 2>&1
# Avisos si un disco falla (mdmonitor deja el aviso en el journal y en el correo de root)
systemctl enable --now mdmonitor.service >/dev/null 2>&1 || true

echo
cat /proc/mdstat
df -h "$MONTAJE"
