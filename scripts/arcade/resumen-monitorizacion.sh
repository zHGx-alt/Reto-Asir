#!/bin/sh
# =============================================================================
# Almi-Chain · Tarea 18 · Resumen de uno o varios CSV de monitor-recreativa.sh
#
# Uso:  sh resumen-monitorizacion.sh fichero1.csv [fichero2.csv ...]
# Muestra una fila por fichero (por ejemplo, antes y después de optimizar) con
# medias y valores extremos. Necesita awk (lo trae cualquier Linux; en Batocera
# conviene ejecutarlo en el PC con los CSV copiados).
# =============================================================================

[ $# -ge 1 ] || { sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

printf '%-34s %8s %8s %8s %10s %10s %8s %9s\n' "fichero" "muestras" "cpu_med" "cpu_max" "mem_usada" "mem_libre_min" "temp_max" "proc_cpu"
for f in "$@"; do
    [ -r "$f" ] || { echo "No se puede leer $f" >&2; continue; }
    awk -F, -v nombre="$(basename "$f")" '
        NR == 1 { next }
        {
            n++
            cpu += $3; if (n == 1 || $3 > cpumax) cpumax = $3
            mem += $6
            if (n == 1 || $7 < memlibre) memlibre = $7
            if ($9 != "" && (tn == 0 || $9 > tmax)) tmax = $9
            if ($9 != "") tn++
            pcpu += $10
        }
        END {
            if (n == 0) { printf "%-34s sin datos\n", nombre; exit }
            t = (tn > 0) ? sprintf("%.1f", tmax) : "n/d"
            printf "%-34s %8d %7.1f%% %7.1f%% %7.0f MB %8.0f MB %8s %8.1f%%\n", nombre, n, cpu/n, cpumax, mem/n, memlibre, t, pcpu/n
        }' "$f"
done
