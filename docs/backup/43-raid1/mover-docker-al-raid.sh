#!/usr/bin/env bash
# Tarea 43 · Lleva los datos vivos (PostgreSQL y adjuntos de Odoo) al RAID 1, como pide el enunciado:
# «Esta BD se almacenará en un dispositivo redundante». Automatiza la sección 7 de DOCUMENTACION.md.
#
#   1. Comprueba que el RAID está montado en /srv/datos, sano ([UU]) y con sitio.
#   2. Hace una copia de seguridad justo antes (backup-odoo, tarea 44).
#   3. Para Odoo y Docker, copia /var/lib/docker a /srv/datos/docker y lo configura como data-root.
#   4. Hace que Docker arranque siempre DESPUÉS de montar el RAID (RequiresMountsFor).
#   5. Arranca y comprueba: data-root nuevo, contenedores en marcha y login de Odoo con 200.
#   El directorio antiguo se renombra a /var/lib/docker.antiguo (no se borra): se borra a mano cuando todo vaya bien.
#
# Uso:  sudo ./mover-docker-al-raid.sh        (si ya está movido, solo comprueba)
set -euo pipefail

RAID=/srv/datos
NUEVO=$RAID/docker
DIR_ODOO=/opt/odoo
log() { printf '\n==> %s\n' "$*"; }
falla() { echo "ERROR: $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || falla "ejecuta el script con sudo: sudo $0"

log "1/5 Comprobaciones"
mountpoint -q "$RAID" || falla "$RAID no está montado (tarea 43)"
estado=$(awk '/^md/{getline; print $NF; exit}' /proc/mdstat)
[[ $estado == "[UU]" ]] || falla "el RAID no está sano ($estado): primero hay que repararlo (sección 5)"
actual=$(docker info --format '{{.DockerRootDir}}')
echo "  RAID $estado montado en $RAID; Docker usa $actual"
if [[ $actual == "$NUEVO" ]]; then
  echo "  Ya está en el RAID: no hay nada que mover."
else
  usado=$(du -sm /var/lib/docker | cut -f1)
  libre=$(df -m --output=avail "$RAID" | tail -1)
  echo "  Datos de Docker: ${usado} MB · libre en el RAID: ${libre} MB"
  (( libre > usado * 2 )) || falla "no hay sitio suficiente en el RAID (hace falta el doble de lo que ocupa Docker)"

  log "2/5 Copia de seguridad antes del cambio"
  if systemctl list-unit-files backup-odoo.service >/dev/null 2>&1; then
    systemctl start backup-odoo.service && echo "  Copia hecha (journalctl -u backup-odoo)"
  else
    echo "  AVISO: no está instalado backup-odoo (tarea 44): se sigue sin copia"
  fi

  log "3/5 Parando Odoo y Docker y copiando los datos"
  (cd "$DIR_ODOO" && docker compose down)
  systemctl stop docker.socket docker.service
  command -v rsync >/dev/null || DEBIAN_FRONTEND=noninteractive apt-get install -y -qq rsync >/dev/null
  rsync -aHAX --info=progress2 /var/lib/docker/ "$NUEVO/"
  mkdir -p /etc/docker
  if [[ -s /etc/docker/daemon.json ]]; then
    python3 - "$NUEVO" <<'EOF'
import json, sys
f = "/etc/docker/daemon.json"
conf = json.load(open(f))
conf["data-root"] = sys.argv[1]
json.dump(conf, open(f, "w"), indent=2)
EOF
  else
    printf '{\n  "data-root": "%s"\n}\n' "$NUEVO" > /etc/docker/daemon.json
  fi
  mv /var/lib/docker /var/lib/docker.antiguo
  echo "  Copiado. El directorio antiguo queda en /var/lib/docker.antiguo"
fi

log "4/5 Docker arranca después de montar el RAID"
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/90-raid.conf <<EOF
[Unit]
RequiresMountsFor=$RAID
EOF
systemctl daemon-reload
systemctl start docker.service
(cd "$DIR_ODOO" && docker compose up -d)

log "5/5 Comprobación"
sleep 15
echo "  data-root: $(docker info --format '{{.DockerRootDir}}')"
docker volume inspect -f '  {{.Name}}: {{.Mountpoint}}' odoo_odoo-db-data odoo_odoo-web-data
(cd "$DIR_ODOO" && docker compose ps --format '  {{.Service}}: {{.Status}}')
codigo=$(curl -sk -o /dev/null -w '%{http_code}' http://127.0.0.1:8069/web/login || true)
echo "  Login de Odoo: $codigo (esperado 200)"
[[ $(docker info --format '{{.DockerRootDir}}') == "$NUEVO" && $codigo == 200 ]] || falla "algo no ha ido bien: revisa la salida"
echo
echo "Listo: la base de datos y los adjuntos están en el RAID."
echo "Siguiente: repetir la simulación de fallo con Odoo funcionando (DOCUMENTACION.md, sección 7) y,"
echo "cuando todo vaya bien unos días, borrar /var/lib/docker.antiguo."
