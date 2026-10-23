#!/usr/bin/env bash
# Tarea 44 · Instala el backup 3-2-1 de Odoo: restic, contraseña, repositorios, disco USB y timer diario.
#
# Uso:  sudo ./instalar-backup.sh [/dev/sdX]
#   /dev/sdX (opcional): disco USB externo NUEVO y VACÍO para prepararlo (se formatea con la etiqueta BACKUP_USB).
#   Idempotente: lo que ya existe (contraseña, repositorio, USB preparado) no se toca.
set -euo pipefail

ORIGEN="$(cd "$(dirname "$0")" && pwd)"
PASS=/root/.config/backup-odoo/restic.pass
REPO_RAID=/srv/datos/restic

log() { printf '\n==> %s\n' "$*"; }
[[ $EUID -eq 0 ]] || { echo "Ejecuta con sudo" >&2; exit 1; }
mountpoint -q /srv/datos || { echo "ERROR: falta el RAID en /srv/datos (tarea 43)" >&2; exit 1; }

log "1/5 Instalando restic"
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq restic >/dev/null
restic version

log "2/5 Contraseña de cifrado"
if [[ ! -f $PASS ]]; then
  install -d -m 700 "$(dirname "$PASS")"
  (umask 077; openssl rand -base64 32 > "$PASS")
  echo "  Creada en $PASS (permisos 600)."
  echo "  ⚠️  GUÁRDALA TAMBIÉN FUERA DEL SERVIDOR (gestor de contraseñas del gerente): sin ella las copias NO se pueden recuperar."
else
  echo "  Ya existe: se mantiene"
fi

log "3/5 Repositorio en el RAID"
if [[ -f $REPO_RAID/config ]]; then
  echo "  Ya existe"
else
  install -d -m 700 "$REPO_RAID"
  restic -r "$REPO_RAID" init --password-file "$PASS"
fi

log "4/5 Disco USB externo"
install -d -m 700 /mnt/usb-backup
grep -q "LABEL=BACKUP_USB" /etc/fstab || \
  echo "LABEL=BACKUP_USB  /mnt/usb-backup  ext4  noauto,nofail  0  0" >> /etc/fstab
systemctl daemon-reload
if [[ -n ${1:-} ]]; then
  USB=$1
  DISCO_SISTEMA=/dev/$(lsblk -no PKNAME "$(findmnt -no SOURCE /)")
  [[ -b $USB && $USB != "$DISCO_SISTEMA" ]] || { echo "ERROR: $USB no vale" >&2; exit 1; }
  if [[ $(blkid -s LABEL -o value "$USB" 2>/dev/null) == BACKUP_USB ]]; then
    echo "  $USB ya está preparado"
  elif [[ $(lsblk -no NAME "$USB" | wc -l) -gt 1 || -n $(blkid -p "$USB" 2>/dev/null) ]]; then
    echo "ERROR: $USB tiene datos. No se formatea." >&2; exit 1
  else
    mkfs.ext4 -q -L BACKUP_USB "$USB"
    echo "  $USB formateado con la etiqueta BACKUP_USB"
  fi
else
  echo "  (sin disco indicado: se usará cualquier disco con la etiqueta BACKUP_USB que esté conectado)"
fi

log "5/5 Script y timer diario (02:30)"
install -m 750 "$ORIGEN/backup-odoo.sh" /usr/local/sbin/backup-odoo.sh
cat > /etc/systemd/system/backup-odoo.service <<'EOF'
[Unit]
Description=Copia de seguridad 3-2-1 cifrada de Odoo
After=docker.service srv-datos.mount
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/backup-odoo.sh
Nice=10
IOSchedulingClass=idle
EOF
cat > /etc/systemd/system/backup-odoo.timer <<'EOF'
[Unit]
Description=Copia de seguridad diaria de Odoo

[Timer]
OnCalendar=*-*-* 02:30:00
RandomizedDelaySec=10min
# Si el servidor estaba apagado a esa hora, la copia se hace al encenderlo
Persistent=true

[Install]
WantedBy=timers.target
EOF
systemctl daemon-reload
systemctl enable --now backup-odoo.timer
systemctl list-timers backup-odoo.timer --no-pager
