#!/usr/bin/env bash
# Tarea 44 · Copia de seguridad 3-2-1 cifrada de Odoo (la ejecuta cada noche backup-odoo.timer)
#
#   Copia 1: los datos vivos (PostgreSQL + adjuntos de Odoo + configuración)
#   Copia 2: repositorio restic en el RAID 1          → /srv/datos/restic
#   Copia 3: repositorio restic en el disco USB externo → /mnt/usb-backup/restic (si está conectado)
#
# restic cifra con AES-256 y deduplica: cada copia diaria solo ocupa lo que ha cambiado.
set -euo pipefail

export RESTIC_PASSWORD_FILE=/root/.config/backup-odoo/restic.pass
export RESTIC_CACHE_DIR=/var/cache/restic   # con systemd no hay $HOME: sin esto restic va sin caché (más lento)
REPO_RAID=/srv/datos/restic
REPO_USB=/mnt/usb-backup/restic
USB_LABEL=BACKUP_USB
COMPOSE=/opt/odoo/docker-compose.yml
VOLUMEN_ADJUNTOS=/var/lib/docker/volumes/odoo_odoo-web-data/_data
TEMP=/srv/datos/temp-backup
RETENCION=(--keep-daily 7 --keep-weekly 4 --keep-monthly 6)

log() { echo "[backup-odoo] $*"; }

set -a; source /opt/odoo/.env; set +a
mountpoint -q /srv/datos || { log "ERROR: el RAID /srv/datos no está montado"; exit 1; }

# 1. Volcado consistente de la base de datos (formato custom de pg_dump: comprimido y restaurable con pg_restore)
install -d -m 700 "$TEMP"
log "Volcando la base de datos ${ODOO_DB}"
docker compose -f "$COMPOSE" exec -T db pg_dump -U "$POSTGRES_USER" -Fc "$ODOO_DB" > "$TEMP/${ODOO_DB}.dump"
docker compose -f "$COMPOSE" exec -T db pg_dumpall -U "$POSTGRES_USER" --globals-only > "$TEMP/globals.sql"
log "Volcado: $(du -h "$TEMP/${ODOO_DB}.dump" | cut -f1)"

# 2. Copia en el RAID
log "Copia 2/3 → RAID ($REPO_RAID)"
restic -r "$REPO_RAID" backup --tag odoo --host servidor-erp \
  "$TEMP" "$VOLUMEN_ADJUNTOS" /opt/odoo
restic -r "$REPO_RAID" forget --tag odoo "${RETENCION[@]}" --prune
restic -r "$REPO_RAID" check

# 3. Copia en el USB externo (si está conectado)
DISPOSITIVO_USB=$(blkid -L "$USB_LABEL" 2>/dev/null || true)
if [[ -n $DISPOSITIVO_USB ]]; then
  mountpoint -q /mnt/usb-backup || mount /mnt/usb-backup
  if [[ ! -f $REPO_USB/config ]]; then
    restic -r "$REPO_USB" init --from-repo "$REPO_RAID" --from-password-file "$RESTIC_PASSWORD_FILE" --copy-chunker-params
  fi
  log "Copia 3/3 → USB externo ($DISPOSITIVO_USB)"
  restic -r "$REPO_USB" copy --from-repo "$REPO_RAID" --from-password-file "$RESTIC_PASSWORD_FILE" --tag odoo
  restic -r "$REPO_USB" forget --tag odoo "${RETENCION[@]}" --prune
  restic -r "$REPO_USB" check
  sync; umount /mnt/usb-backup   # desmontado: se puede sacar y llevar fuera del local
  log "USB desmontado: ya se puede retirar"
else
  log "AVISO: USB externo no conectado → hoy solo hay copia en el RAID (no se cumple el 3-2-1)"
fi

rm -rf "$TEMP"
log "Instantáneas en el RAID:"
restic -r "$REPO_RAID" snapshots --tag odoo --compact
log "Copia terminada correctamente"
