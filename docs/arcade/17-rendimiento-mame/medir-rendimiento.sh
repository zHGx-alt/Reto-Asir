#!/usr/bin/env bash
# Tarea 17 · Toma UNA muestra de rendimiento de la recreativa y la añade a un CSV.
# Ejecutar justo después de arrancar (en tty2 o por SSH), una vez por reinicio:
#   sudo ./medir-rendimiento.sh antes            # arranque, RAM, procesos...
#   sudo ./medir-rendimiento.sh antes --bench    # además, benchmark de MAME (≈2 min)
set -euo pipefail
export LC_ALL=C   # números con punto decimal (si no, la coma del locale español rompe el CSV)

ETIQUETA="${1:?Uso: sudo $0 <etiqueta> [--bench]}"
CSV="${CSV:-/root/rendimiento.csv}"
MAME=/usr/games/mame
ROMS=/home/arcade/roms
SEG_BENCH=30

[[ $EUID -eq 0 ]] || { echo "Ejecuta con sudo" >&2; exit 1; }

# Esperar a que MAME esté abierto y dejar que el sistema se asiente
for _ in $(seq 1 60); do pgrep -u arcade -x mame >/dev/null && break; sleep 1; done
PID_MAME=$(pgrep -u arcade -x mame | head -1) || { echo "MAME no está en marcha" >&2; exit 1; }
sleep 20

# Tiempos de arranque (systemd-analyze puede tardar unos segundos en tenerlos)
until systemd-analyze >/dev/null 2>&1; do sleep 1; done
LINEA=$(systemd-analyze | head -1)
T_KERNEL=$(grep -oP '[\d.]+(?=s \(kernel\))' <<<"$LINEA")
T_USER=$(grep -oP '[\d.]+(?=s \(userspace\))' <<<"$LINEA")
T_TOTAL=$(grep -oP '(?<== )[\d.]+(?=s)' <<<"$LINEA")

# Segundo (desde que arrancó el kernel) en que se abrió MAME
TICKS=$(awk '{print $22}' "/proc/${PID_MAME}/stat")
T_MAME=$(awk -v t="$TICKS" -v hz="$(getconf CLK_TCK)" 'BEGIN{printf "%.2f", t/hz}')

RAM_USADA=$(free -m | awk '/^Mem:/{print $3}')
RSS_MAME=$(( $(ps -o rss= -p "$PID_MAME") / 1024 ))
PROCESOS=$(ps -e --no-headers | wc -l)
SERVICIOS=$(systemctl list-units --type=service --state=running --no-legend | wc -l)
TIMERS=$(systemctl list-timers --no-legend | wc -l)
DISCO_MB=$(df -m / | awk 'NR==2{print $3}')

bench() {   # velocidad media (%) de un juego con -bench; 100 % = velocidad real
  (cd /tmp && sudo -u arcade "$MAME" -rompath "$ROMS" -bench "$SEG_BENCH" "$1" 2>/dev/null) \
    | grep -oP '(?<=Average speed: )[\d.]+'
}
B_GRIDLEE=""; B_ROBBY=""
if [[ "${2:-}" == "--bench" ]]; then
  B_GRIDLEE=$(bench gridlee)
  B_ROBBY=$(bench robby)
fi

[[ -f "$CSV" ]] || echo "etiqueta,fecha,kernel_s,userspace_s,total_s,mame_abierto_s,ram_usada_mb,rss_mame_mb,procesos,servicios,timers,disco_mb,bench_gridlee_pct,bench_robby_pct" > "$CSV"
FILA="$ETIQUETA,$(date '+%F %T'),$T_KERNEL,$T_USER,$T_TOTAL,$T_MAME,$RAM_USADA,$RSS_MAME,$PROCESOS,$SERVICIOS,$TIMERS,$DISCO_MB,$B_GRIDLEE,$B_ROBBY"
echo "$FILA" >> "$CSV"
echo "$FILA"
