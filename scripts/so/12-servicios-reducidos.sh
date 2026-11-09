#!/bin/bash
# Tarea 12 · Ubuntu del gerente: desactiva los servicios que el despacho no necesita (rúbrica ISO RA1, nivel 5:
# «el sistema queda endurecido (mínimos privilegios, servicios reducidos)») y deja la evidencia antes/después.
# Uso: sudo bash scripts/so/12-servicios-reducidos.sh [fichero-de-evidencia]
# Se puede repetir: los que ya están desactivados o no existen se saltan.
set -euo pipefail
[ "$(id -u)" = 0 ] || { echo "Lánzalo con sudo"; exit 1; }
OUT=${1:-/root/ubu-11-servicios-reducidos.txt}   # ruta de la evidencia

# Qué se quita y por qué. CUPS se queda: el gerente puede imprimir por USB.
declare -A QUITAR=(
  [cups-browsed.service]="busca impresoras en la red y las añade solas; la del gerente va por USB"
  [avahi-daemon.service]="anuncia el equipo en la red local (mDNS); en el despacho no hace falta"
  [avahi-daemon.socket]="activa avahi-daemon bajo demanda"
  [ModemManager.service]="gestiona módems 3G/4G; el equipo no tiene"
  [whoopsie.service]="envía informes de fallos a Canonical"
  [kerneloops.service]="envía fallos del núcleo a Canonical"
  [apport.service]="recoge informes de fallos para enviarlos"
)

habilitados() { systemctl list-unit-files --type=service --type=socket --state=enabled --no-legend | awk '{print $1}' | LC_ALL=C sort; }

ANTES=$(habilitados)
for u in "${!QUITAR[@]}"; do
  if systemctl cat "$u" >/dev/null 2>&1 && systemctl is-enabled "$u" 2>/dev/null | grep -qx enabled; then
    systemctl disable --now "$u" >/dev/null 2>&1 && echo "Desactivado: $u (${QUITAR[$u]})"
  fi
done
DESPUES=$(habilitados)

{ echo "# Tarea 12 · Ubuntu del gerente: servicios reducidos ($(date '+%F %H:%M'))"
  echo; echo "## Servicios y sockets habilitados ANTES ($(echo "$ANTES" | grep -c .))"; echo "$ANTES"
  echo; echo "## Servicios y sockets habilitados DESPUÉS ($(echo "$DESPUES" | grep -c .))"; echo "$DESPUES"
  echo; echo "## Quitados en esta ejecución"; LC_ALL=C comm -23 <(echo "$ANTES") <(echo "$DESPUES") || true
  echo; echo "## Motivo de cada uno"; for u in "${!QUITAR[@]}"; do echo "- $u: ${QUITAR[$u]}"; done
  echo; echo '$ ss -tulpn (puertos a la escucha después)'; ss -tulpn
} > "$OUT"
echo; echo "HECHO. Evidencia en $OUT"
