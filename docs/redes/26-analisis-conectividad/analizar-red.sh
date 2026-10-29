#!/usr/bin/env bash
# Tarea 26 · Batería de pruebas con nmap contra la red del local, con veredicto automático.
#
# Uso:  bash analizar-red.sh lan        (desde un equipo de la LAN 192.168.10.0/24, p. ej. el PC del gerente)
#       bash analizar-red.sh invitados  (desde un portátil conectado a la Wi-Fi de invitados)
#
# Guarda la salida de cada prueba en evidencias/<rol>-<fecha>/ y un resumen.txt con OK / REVISAR / INFO.
# Las direcciones salen del plan de la tarea 23; se pueden cambiar con variables de entorno, por ejemplo:
#   SERVIDOR=192.168.10.10 TPV1=192.168.10.31 bash analizar-red.sh lan
#
# ⚠️ Escanear solo la red del reto y con permiso del profesor: en otras redes puede ser ilegal.
set -uo pipefail
export LC_ALL=C

ROL="${1:-}"
[[ "$ROL" == lan || "$ROL" == invitados ]] || { sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
command -v nmap >/dev/null || { echo "Falta nmap: sudo apt install nmap (en Windows: https://nmap.org/download)" >&2; exit 1; }

RED_LAN="${RED_LAN:-192.168.10.0/24}"
ROUTER="${ROUTER:-192.168.10.1}"
ROUTER2="${ROUTER2:-192.168.10.2}"
SERVIDOR="${SERVIDOR:-192.168.10.10}"
GERENTE="${GERENTE:-192.168.10.20}"
TPV1="${TPV1:-192.168.10.31}"
TPV2="${TPV2:-192.168.10.32}"

DIR="$(cd "$(dirname "$0")" && pwd)/evidencias/${ROL}-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DIR"
RESUMEN="$DIR/resumen.txt"
MI_IP=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "src") print $(i + 1)}')
GW=$(ip -4 route show default 2>/dev/null | awk '{print $3; exit}')
{
    echo "Tarea 26 · Análisis de conectividad · rol: $ROL · $(date '+%d/%m/%Y %H:%M')"
    echo "Equipo: $(hostname) · IP: ${MI_IP:-?} · puerta de enlace: ${GW:-?} · $(nmap --version | head -1)"
    echo
} > "$RESUMEN"

n=0
# prueba <nombre> <descripción> <esperado> <argumentos de nmap...>   → deja los puertos abiertos en $ABIERTOS y los hosts en $HOSTS
prueba() {
    local nombre=$1 desc=$2 esperado=$3; shift 3
    n=$((n + 1))
    local base; base=$(printf '%s/%02d-%s' "$DIR" "$n" "$nombre")
    echo ">> [$n] $desc"
    nmap "$@" -oN "$base.txt" -oG "$base.gnmap" >/dev/null 2>"$base.err"
    ABIERTOS=$(grep -oE '[0-9]+/open/' "$base.gnmap" | cut -d/ -f1 | sort -n | uniq | paste -sd, -)
    HOSTS=$(grep -c 'Status: Up' "$base.gnmap")
    DESC=$desc; ESPERADO=$esperado
}
veredicto() { # veredicto OK|REVISAR|INFO <detalle>
    printf '[%-7s] %2d. %s\n           Esperado: %s\n           Obtenido: %s\n\n' "$1" "$n" "$DESC" "$ESPERADO" "$2" | tee -a "$RESUMEN"
}

if [[ "$ROL" == lan ]]; then
    prueba descubrir-lan "Equipos encendidos en la LAN" "Los de la tabla 4.3 de la tarea 23 (.1, .2, .3, .10, .20, .31, .32)" -sn "$RED_LAN"
    veredicto INFO "$HOSTS equipos: $(grep 'Status: Up' "$DIR/01-descubrir-lan.gnmap" | awk '{print $2}' | paste -sd' ' -)"

    prueba servidor-todos "Servidor $SERVIDOR: todos los puertos TCP" "Solo 22, 80 y 443 (tarea 46, comprobación 2)" -Pn -T4 -p- "$SERVIDOR"
    if [[ "$ABIERTOS" == "22,80,443" ]]; then veredicto OK "$ABIERTOS"; else veredicto REVISAR "${ABIERTOS:-ninguno}"; fi

    prueba servidor-odoo-bd "Servidor: Odoo directo (8069) y PostgreSQL (5432)" "Cerrados: solo se entra por nginx con HTTPS" -Pn -p 8069,5432 "$SERVIDOR"
    if [[ -z "$ABIERTOS" ]]; then veredicto OK "cerrados o filtrados"; else veredicto REVISAR "abiertos: $ABIERTOS"; fi

    prueba servidor-versiones "Servidor: servicios y versiones" "OpenSSH y nginx" -Pn -sV -p 22,80,443 "$SERVIDOR"
    veredicto INFO "$(grep -E '^[0-9]+/tcp' "$DIR/04-servidor-versiones.txt" | awk '{$2=$2; print}' | paste -sd';' - | sed 's/;/; /g')"

    prueba servidor-tls "Servidor: versiones de TLS en el 443" "Solo TLS 1.2 y 1.3" -Pn --script ssl-enum-ciphers -p 443 "$SERVIDOR"
    TLS=$(grep -oE 'TLSv1\.[0-3]' "$DIR/05-servidor-tls.txt" | sort -u | paste -sd' ' -)
    if [[ -n "$TLS" && "$TLS" != *TLSv1.0* && "$TLS" != *TLSv1.1* ]]; then veredicto OK "$TLS"; else veredicto REVISAR "${TLS:-sin datos de TLS}"; fi

    for par in "tpv1:$TPV1" "tpv2:$TPV2" "gerente:$GERENTE"; do
        nom=${par%%:*}; ip=${par#*:}
        prueba "$nom" "$nom ($ip): 1000 puertos más comunes" "Ninguno abierto (cortafuegos del equipo, tarea 23 prueba 8)" -Pn -T4 "$ip"
        if [[ -z "$ABIERTOS" ]]; then veredicto OK "ninguno abierto"; else veredicto REVISAR "abiertos: $ABIERTOS"; fi
    done

    prueba router "Router 1 ($ROUTER): servicios de gestión" "DNS (53) y panel web; sin Telnet (23) ni FTP (21)" -Pn -p 21,22,23,53,80,443,1900,8080 "$ROUTER"
    if [[ ",$ABIERTOS," == *",23,"* || ",$ABIERTOS," == *",21,"* ]]; then veredicto REVISAR "abiertos: $ABIERTOS"; else veredicto OK "abiertos: ${ABIERTOS:-ninguno}"; fi
else
    prueba descubrir-lan "Desde invitados: ¿se ven equipos de la LAN?" "Ninguno (tarea 46, comprobación 1)" -sn "$RED_LAN"
    if [[ "$HOSTS" -eq 0 ]]; then veredicto OK "0 equipos"; else veredicto REVISAR "$HOSTS equipos visibles"; fi

    prueba puertos-lan "Desde invitados: puertos 22, 80, 443 y 8069 de toda la LAN" "Ninguno abierto (todo filtrado)" -Pn -T4 -p 22,80,443,8069 "$RED_LAN"
    if [[ -z "$ABIERTOS" ]]; then veredicto OK "ninguno abierto"; else veredicto REVISAR "abiertos: $ABIERTOS"; fi

    prueba paneles-router "Desde invitados: paneles de los routers ($ROUTER y $ROUTER2)" "Cerrados (tarea 25, prueba W6)" -Pn -p 80,443 "$ROUTER" "$ROUTER2"
    if [[ -z "$ABIERTOS" ]]; then veredicto OK "cerrados o filtrados"; else veredicto REVISAR "abiertos: $ABIERTOS"; fi

    if [[ -n "$MI_IP" ]]; then
        RED_INV="${RED_INV:-${MI_IP%.*}.0/24}"
        prueba descubrir-invitados "Otros clientes en la red de invitados ($RED_INV)" "Solo este equipo y la puerta de enlace (aislamiento de clientes, W7)" -sn "$RED_INV"
        veredicto INFO "$HOSTS equipos: $(grep 'Status: Up' "$DIR/04-descubrir-invitados.gnmap" | awk '{print $2}' | paste -sd' ' -)"
    fi
    if [[ -n "$GW" ]]; then
        prueba panel-gw "Panel de la puerta de enlace de invitados ($GW)" "Cerrado o con acceso solo desde la LAN" -Pn -p 80,443 "$GW"
        if [[ -z "$ABIERTOS" ]]; then veredicto OK "cerrado o filtrado"; else veredicto REVISAR "abiertos: $ABIERTOS (¿se puede entrar al panel desde invitados?)"; fi
    fi
fi

rm -f "$DIR"/*.gnmap
find "$DIR" -name '*.err' -empty -delete
echo "Resultados en $DIR"
echo "$(grep -c '^\[OK' "$RESUMEN") OK · $(grep -c '^\[REVISAR' "$RESUMEN") REVISAR · $(grep -c '^\[INFO' "$RESUMEN") INFO" | tee -a "$RESUMEN"
