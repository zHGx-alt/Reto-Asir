#!/usr/bin/env bash
# Tarea 43 · Lleva los datos vivos (PostgreSQL y adjuntos de Odoo) al RAID 1, como pide el enunciado:
# «Esta BD se almacenará en un dispositivo redundante». Automatiza la sección 7 de DOCUMENTACION.md.
#
# Solo se mueven los VOLÚMENES de Docker (/var/lib/docker/volumes: la base de datos y los adjuntos), no todo
# /var/lib/docker: las imágenes ocupan varios GB, se vuelven a descargar y no caben en el RAID de 5 GB
# (27/10/2026: Docker ocupaba 6097 MB y el RAID tenía 4454 MB libres).
#
#   1. Comprueba que el RAID está montado en /srv/datos, sano ([UU]) y con sitio para los volúmenes.
#   2. Hace una copia de seguridad justo antes (backup-odoo, tarea 44).
#   3. Para Odoo y Docker y copia los volúmenes a /srv/datos/docker-volumes.
#   4. Monta esa carpeta sobre /var/lib/docker/volumes (bind en /etc/fstab, que exige el RAID) y hace que
#      Docker arranque siempre DESPUÉS de ese montaje: si el RAID no está, Odoo no arranca con una BD vacía.
#   5. Arranca y comprueba: volúmenes en md0, contenedores en marcha y login de Odoo con 200.
#   Los volúmenes antiguos quedan en /var/lib/docker/volumes.antiguo (no se borran): se borran a mano después.
#
# Uso:  sudo ./mover-docker-al-raid.sh        (si ya está movido, solo comprueba)
set -euo pipefail

RAID=/srv/datos
VOLUMENES=/var/lib/docker/volumes
NUEVO=$RAID/docker-volumes
DIR_ODOO=/opt/odoo
log() { printf '\n==> %s\n' "$*"; }
falla() { echo "ERROR: $*" >&2; exit 1; }
en_raid() { [[ $(findmnt -no SOURCE --target "$VOLUMENES" 2>/dev/null) == *md0* ]]; }

[[ $EUID -eq 0 ]] || falla "ejecuta el script con sudo: sudo $0"

log "1/5 Comprobaciones"
mountpoint -q "$RAID" || falla "$RAID no está montado (tarea 43)"
estado=$(awk '/^md/{getline; print $NF; exit}' /proc/mdstat)
[[ $estado == "[UU]" ]] || falla "el RAID no está sano ($estado): primero hay que repararlo (sección 5)"
echo "  RAID $estado montado en $RAID"
if en_raid; then
  echo "  Los volúmenes ya están en el RAID: no hay nada que mover."
else
  usado=$(du -sm "$VOLUMENES" | cut -f1)
  libre=$(df -m --output=avail "$RAID" | tail -1 | tr -d ' ')
  echo "  Volúmenes de Docker: ${usado} MB · libre en el RAID: ${libre} MB"
  (( libre > usado * 2 )) || falla "no hay sitio suficiente en el RAID (hace falta el doble de lo que ocupan los volúmenes)"

  log "2/5 Copia de seguridad antes del cambio"
  if systemctl list-unit-files backup-odoo.service >/dev/null 2>&1; then
    systemctl start backup-odoo.service && echo "  Copia hecha (journalctl -u backup-odoo)"
  else
    echo "  AVISO: no está instalado backup-odoo (tarea 44): se sigue sin copia"
  fi

  log "3/5 Parando Odoo y Docker y copiando los volúmenes"
  (cd "$DIR_ODOO" && docker compose down)
  systemctl stop docker.socket docker.service
  command -v rsync >/dev/null || DEBIAN_FRONTEND=noninteractive apt-get install -y -qq rsync >/dev/null
  install -d -m 701 "$NUEVO"
  rsync -aHAX --info=progress2 "$VOLUMENES/" "$NUEVO/"
  mv "$VOLUMENES" "$VOLUMENES.antiguo"
  install -d -m 701 "$VOLUMENES"
  echo "  Copiado. Los volúmenes antiguos quedan en $VOLUMENES.antiguo"

  log "4/5 Montaje en el RAID"
  grep -q " $VOLUMENES " /etc/fstab || \
    echo "$NUEVO  $VOLUMENES  none  bind,x-systemd.requires-mounts-for=$RAID  0  0" >> /etc/fstab
  systemctl daemon-reload
  mount "$VOLUMENES"
fi

# Docker arranca después del RAID y del montaje de los volúmenes (y no arranca sin ellos)
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/90-raid.conf <<EOF
[Unit]
RequiresMountsFor=$RAID $VOLUMENES
EOF
systemctl daemon-reload
systemctl start docker.service
(cd "$DIR_ODOO" && docker compose up -d)

log "5/5 Comprobación"
sleep 15
findmnt --target "$VOLUMENES" -o TARGET,SOURCE,FSTYPE
docker volume inspect -f '  {{.Name}}: {{.Mountpoint}}' odoo_odoo-db-data odoo_odoo-web-data
(cd "$DIR_ODOO" && docker compose ps --format '  {{.Service}}: {{.Status}}')
codigo=$(curl -sk -o /dev/null -w '%{http_code}' http://127.0.0.1:8069/web/login || true)
echo "  Login de Odoo: $codigo (esperado 200)"
en_raid && [[ $codigo == 200 ]] || falla "algo no ha ido bien: revisa la salida"
echo
echo "Listo: la base de datos y los adjuntos están en el RAID."
echo "Siguiente: sudo ./simular-fallo-con-odoo.sh (sección 7) y, cuando todo vaya bien unos días,"
echo "borrar $VOLUMENES.antiguo."
