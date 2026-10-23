#!/usr/bin/env bash
# Tarea 44 · Copia de seguridad 3-2-1 cifrada de Odoo (la ejecuta cada noche backup-odoo.timer)
#
#   Copia 1: los datos vivos (PostgreSQL: bases de Odoo y almi_chain + adjuntos de Odoo + configuración)
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
ESTADO=/var/lib/backup-odoo          # fecha de la última copia en el USB
DIAS_MAX_SIN_USB=7                   # el USB se renueva fuera del local cada lunes (tarea 44, sección 4)
TEMP=/srv/datos/temp-backup
RETENCION=(--keep-daily 7 --keep-weekly 4 --keep-monthly 6)

log() { echo "[backup-odoo] $*"; }

set -a; source /opt/odoo/.env; set +a
mountpoint -q /srv/datos || { log "ERROR: el RAID /srv/datos no está montado"; exit 1; }
# Ruta real del volumen de adjuntos: sigue valiendo si los datos de Docker se mueven al RAID (tarea 43, sección 9)
VOLUMEN_ADJUNTOS=$(docker volume inspect -f '{{.Mountpoint}}' odoo_odoo-web-data)

# 1. Volcado consistente de la base de datos (formato custom de pg_dump: comprimido y restaurable con pg_restore)
install -d -m 700 "$TEMP"
log "Volcando la base de datos ${ODOO_DB}"
docker compose -f "$COMPOSE" exec -T db pg_dump -U "$POSTGRES_USER" -Fc "$ODOO_DB" > "$TEMP/${ODOO_DB}.dump"
docker compose -f "$COMPOSE" exec -T db pg_dumpall -U "$POSTGRES_USER" --globals-only > "$TEMP/globals.sql"
log "Volcado: $(du -h "$TEMP/${ODOO_DB}.dump" | cut -f1)"
# Base del diseño de la tarea 40 (almi_chain), si está creada en el mismo PostgreSQL (tarea 41)
if docker compose -f "$COMPOSE" exec -T db psql -U "$POSTGRES_USER" -d postgres -tAc      "SELECT 1 FROM pg_database WHERE datname = 'almi_chain'" | grep -q 1; then
  docker compose -f "$COMPOSE" exec -T db pg_dump -U "$POSTGRES_USER" -Fc almi_chain > "$TEMP/almi_chain.dump"
  log "Volcado almi_chain: $(du -h "$TEMP/almi_chain.dump" | cut -f1)"
fi

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
  install -d -m 700 "$ESTADO"; date +%s > "$ESTADO/ultima-copia-usb"
  log "USB desmontado: ya se puede retirar"
else
  log "AVISO: USB externo no conectado → hoy solo hay copia en el RAID (no se cumple el 3-2-1)"
fi

rm -rf "$TEMP"
log "Instantáneas en el RAID:"
restic -r "$REPO_RAID" snapshots --tag odoo --compact

# Aviso si la copia fuera del local lleva demasiado sin renovarse: el servicio termina con error
# y aparece en "systemctl --failed" (y en OnFailure= cuando se configure el correo).
ultima=$(cat "$ESTADO/ultima-copia-usb" 2>/dev/null || echo 0)
dias=$(( ($(date +%s) - ultima) / 86400 ))
if (( dias > DIAS_MAX_SIN_USB )); then
  log "ERROR: la última copia en el USB es de hace $dias días (máximo $DIAS_MAX_SIN_USB): hay que traer el USB"
  exit 2
fi
log "Copia terminada correctamente"
