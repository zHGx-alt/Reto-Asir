#!/bin/sh
# =============================================================================
# Almi-Chain · Tarea 18 · Monitorización de recursos de la recreativa
#
# Registra cada pocos segundos el uso de CPU, memoria, carga, temperatura y el
# consumo del emulador, y lo guarda en un CSV. Pensado para Batocera (BusyBox),
# pero funciona en cualquier Linux. Solo usa /proc, /sys y órdenes básicas:
# no hay que instalar nada.
#
# Uso:
#   sh monitor-recreativa.sh [-i segundos] [-d segundos] [-e etiqueta] [-o carpeta] [-p proceso]
#
#   -i  intervalo entre muestras (por defecto 5)
#   -d  duración total; 0 = hasta pulsar Ctrl+C (por defecto 300)
#   -e  etiqueta de la prueba, por ejemplo "antes" o "despues" (por defecto "prueba")
#   -o  carpeta de salida (por defecto /userdata/monitor si existe, si no ./monitor)
#   -p  nombre del proceso del emulador a vigilar (por defecto "mame")
#
# Salida: <carpeta>/monitor_<etiqueta>_<fecha>-<hora>.csv
# =============================================================================

INTERVALO=5
DURACION=300
ETIQUETA=prueba
PROCESO=mame
if [ -d /userdata ]; then SALIDA=/userdata/monitor; else SALIDA=./monitor; fi

uso() { sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

while getopts "i:d:e:o:p:h" opt; do
    case $opt in
        i) INTERVALO=$OPTARG ;;
        d) DURACION=$OPTARG ;;
        e) ETIQUETA=$OPTARG ;;
        o) SALIDA=$OPTARG ;;
        p) PROCESO=$OPTARG ;;
        *) uso ;;
    esac
done

# Validaciones: números enteros positivos y etiqueta sin caracteres raros.
case $INTERVALO in ''|*[!0-9]*|0) echo "El intervalo (-i) debe ser un entero mayor que 0." >&2; exit 1 ;; esac
case $DURACION  in ''|*[!0-9]*)   echo "La duración (-d) debe ser un entero (0 = sin límite)." >&2; exit 1 ;; esac
case $ETIQUETA  in *[!A-Za-z0-9_-]*|'') echo "La etiqueta (-e) solo admite letras, números, - y _." >&2; exit 1 ;; esac
case $PROCESO   in *[!A-Za-z0-9_.-]*|'') echo "El proceso (-p) solo admite letras, números, . - y _." >&2; exit 1 ;; esac

mkdir -p "$SALIDA" || { echo "No se puede crear $SALIDA" >&2; exit 1; }
FICHERO="$SALIDA/monitor_${ETIQUETA}_$(date +%Y%m%d-%H%M%S).csv"

# --- Lectura de datos --------------------------------------------------------

# CPU total: deja en CPU_TOTAL y CPU_LIBRE los "jiffies" acumulados.
leer_cpu() {
    read -r _ u n s i w irq sirq st _ < /proc/stat
    CPU_TOTAL=$((u + n + s + i + w + irq + sirq + st))
    CPU_LIBRE=$((i + w))
}

# Primer PID cuyo nombre (comm) coincide con el proceso vigilado.
buscar_pid() {
    PID=
    for d in /proc/[0-9]*; do
        [ -r "$d/comm" ] || continue
        read -r c < "$d/comm" 2>/dev/null || continue
        if [ "$c" = "$PROCESO" ]; then PID=${d#/proc/}; return; fi
    done
}

# CPU (utime+stime) y memoria residente del proceso.
leer_proceso() {
    PROC_JIFFIES=0; PROC_RSS_KB=0
    [ -n "$PID" ] && [ -r "/proc/$PID/stat" ] || return
    read -r linea < "/proc/$PID/stat" 2>/dev/null || return
    resto=${linea##*) }
    set -- $resto
    PROC_JIFFIES=$((${12} + ${13}))
    while read -r k v _; do
        [ "$k" = "VmRSS:" ] && PROC_RSS_KB=$v && break
    done < "/proc/$PID/status" 2>/dev/null
}

leer_memoria() {
    MT=0; MA=0; MF=0; ST=0; SF=0
    while read -r k v _; do
        case $k in
            MemTotal:) MT=$v ;;
            MemFree:) MF=$v ;;
            MemAvailable:) MA=$v ;;
            SwapTotal:) ST=$v ;;
            SwapFree:) SF=$v ;;
        esac
    done < /proc/meminfo
    [ "$MA" -eq 0 ] && MA=$MF   # núcleos antiguos sin MemAvailable
}

# Temperatura más alta de las zonas térmicas, en °C (vacío si no hay sensores).
leer_temperatura() {
    TEMP=
    max=-1
    for z in /sys/class/thermal/thermal_zone*/temp; do
        [ -r "$z" ] || continue
        read -r t < "$z" 2>/dev/null || continue
        case $t in ''|*[!0-9-]*) continue ;; esac
        [ "$t" -gt "$max" ] && max=$t
    done
    [ "$max" -ge 0 ] && TEMP="$((max / 1000)).$(( (max % 1000) / 100 ))"
}

decimal1() { # decimal1 <décimas>  ->  "12.3"
    echo "$(($1 / 10)).$(($1 % 10))"
}

# --- Bucle principal -----------------------------------------------------------

FIN=0
trap 'FIN=1' INT TERM

echo "fecha_hora,segundos,cpu_pct,carga_1min,mem_total_mb,mem_usada_mb,mem_disponible_mb,swap_usada_mb,temp_c,proc_cpu_pct,proc_rss_mb" > "$FICHERO"
echo "Guardando en $FICHERO (cada ${INTERVALO}s; proceso vigilado: $PROCESO). Ctrl+C para parar."

leer_cpu; T0_TOTAL=$CPU_TOTAL; T0_LIBRE=$CPU_LIBRE
buscar_pid; leer_proceso; P0=$PROC_JIFFIES
INICIO=$(date +%s)
MUESTRAS=0

while [ "$FIN" -eq 0 ]; do
    sleep "$INTERVALO" || break
    [ "$FIN" -eq 1 ] && break

    leer_cpu
    DT=$((CPU_TOTAL - T0_TOTAL)); DL=$((CPU_LIBRE - T0_LIBRE))
    if [ "$DT" -gt 0 ]; then CPU10=$(( (1000 * (DT - DL)) / DT )); else CPU10=0; fi
    T0_TOTAL=$CPU_TOTAL; T0_LIBRE=$CPU_LIBRE

    buscar_pid; leer_proceso
    DP=$((PROC_JIFFIES - P0)); [ "$DP" -lt 0 ] && DP=0   # el proceso se reinició
    P0=$PROC_JIFFIES
    if [ "$DT" -gt 0 ]; then PCPU10=$(( (1000 * DP) / DT )); else PCPU10=0; fi

    leer_memoria; leer_temperatura
    read -r CARGA _ < /proc/loadavg

    AHORA=$(date +%s)
    echo "$(date '+%Y-%m-%d %H:%M:%S'),$((AHORA - INICIO)),$(decimal1 $CPU10),$CARGA,$((MT / 1024)),$(((MT - MA) / 1024)),$((MA / 1024)),$(((ST - SF) / 1024)),$TEMP,$(decimal1 $PCPU10),$((PROC_RSS_KB / 1024))" >> "$FICHERO"
    MUESTRAS=$((MUESTRAS + 1))

    if [ "$DURACION" -gt 0 ] && [ $((AHORA - INICIO)) -ge "$DURACION" ]; then break; fi
done

echo "Terminado: $MUESTRAS muestras en $FICHERO"
