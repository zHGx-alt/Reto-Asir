#!/bin/sh
# Tarea 51 · Una muestra de rendimiento de la recreativa Batocera (ejecutar como root justo tras arrancar)
#   ./medir-batocera.sh <etiqueta> [--bench]
ETIQUETA=$1; CSV=/userdata/system/rendimiento.csv
MAME=/usr/bin/mame/mame; ROMS=/userdata/roms/mame; SEG=30
export LC_ALL=C
for _ in $(seq 1 120); do pidof emulationstation >/dev/null && break; sleep 1; done
PID=$(pidof emulationstation | cut -d' ' -f1) || { echo "EmulationStation no arranca"; exit 1; }
sleep 20
HZ=$(getconf CLK_TCK)
T_MENU=$(awk -v hz=$HZ '{printf "%.2f", $22/hz}' /proc/$PID/stat)
RAM=$(free -m | awk '/^Mem:/{print $3}')
RSS=$(( $(awk '/VmRSS/{print $2}' /proc/$PID/status) / 1024 ))
PROCS=$(ps -e | tail -n +2 | wc -l)
SERVICIOS=$(ls /etc/init.d/S* | wc -l)
DISCO=$(df -m /userdata | awk 'NR==2{print $3}')
# MAME de Batocera necesita la pantalla X aunque sea con -bench (sin ella: "No available video device")
bench() { cd /tmp && DISPLAY=:0.0 $MAME -rompath $ROMS -bench $SEG "$1" 2>/dev/null | sed -n 's/.*Average speed: \([0-9.]*\)%.*/\1/p'; }
BG=""; BR=""
if [ "$2" = "--bench" ]; then BG=$(bench gridlee); BR=$(bench robby); fi
[ -f $CSV ] || echo "etiqueta,fecha,menu_abierto_s,ram_usada_mb,rss_frontend_mb,procesos,scripts_init,disco_userdata_mb,bench_gridlee_pct,bench_robby_pct" > $CSV
FILA="$ETIQUETA,$(date '+%F %T'),$T_MENU,$RAM,$RSS,$PROCS,$SERVICIOS,$DISCO,$BG,$BR"
echo "$FILA" >> $CSV; echo "$FILA"
