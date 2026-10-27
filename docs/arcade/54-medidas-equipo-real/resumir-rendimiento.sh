#!/bin/sh
# Tarea 54 · Media y desviación típica, por etiqueta, del CSV de medir-rendimiento.sh (tarea 17).
# Uso:  sh resumir-rendimiento.sh rendimiento.csv
# Salida: una tabla Markdown por columna numérica con «antes», «despues»… y el cambio en %,
# lista para pegar en la documentación. La desviación típica es la poblacional (dividida entre n),
# la misma que usa la tarea 17, para que las tablas se puedan comparar.
set -eu
if [ $# -ne 1 ] || [ ! -r "$1" ]; then echo "Uso: sh $0 rendimiento.csv" >&2; exit 1; fi

LC_ALL=C awk -F, '
    NR == 1 { for (c = 3; c <= NF; c++) col[c] = $c; ncol = NF; next }
    {
        e = $1
        if (!(e in n)) orden[++ne] = e
        n[e]++
        for (c = 3; c <= ncol; c++) if ($c != "") { s[e, c] += $c; q[e, c] += $c * $c; k[e, c]++ }
    }
    function media(e, c)  { return k[e, c] ? s[e, c] / k[e, c] : "" }
    function desv(e, c,   m) {
        m = media(e, c); v = q[e, c] / k[e, c] - m * m
        return v > 0 ? sqrt(v) : 0
    }
    END {
        printf "| Medida |"; for (i = 1; i <= ne; i++) printf " %s (n=%d) |", orden[i], n[orden[i]]
        if (ne >= 2) printf " Cambio |"
        printf "\n|---|"; for (i = 1; i <= ne; i++) printf "---|"; if (ne >= 2) printf "---|"; printf "\n"
        for (c = 3; c <= ncol; c++) {
            printf "| %s |", col[c]
            for (i = 1; i <= ne; i++) {
                e = orden[i]
                if (k[e, c]) printf " %.2f ± %.2f |", media(e, c), desv(e, c); else printf " — |"
            }
            if (ne >= 2) {
                a = media(orden[1], c); b = media(orden[ne], c)
                if (a != "" && b != "" && a != 0) printf " %+.0f %% |", (b - a) / a * 100; else printf " — |"
            }
            printf "\n"
        }
    }' "$1"
