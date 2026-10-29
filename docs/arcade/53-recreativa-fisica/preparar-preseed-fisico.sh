#!/usr/bin/env bash
# Tarea 53 · Genera preseed-local.cfg para instalar la recreativa en el EQUIPO REAL.
#
# Parte del preseed de la VM (tarea 16) y cambia lo que solo sirve en VirtualBox:
#   - La contraseña de "tecnico": en la VM la pone VBoxManage; aquí se pide y se guarda como hash SHA-512.
#   - El disco donde se instala: en la VM es /dev/sda; en el equipo real puede ser otro.
#   - La clave SSH pública del equipo de administración (opcional).
#
# Uso:   bash preparar-preseed-fisico.sh [disco]          (por defecto /dev/sda)
# Ejemplo con disco NVMe:  bash preparar-preseed-fisico.sh /dev/nvme0n1
# Variables opcionales: CLAVE=<fichero .pub> (por defecto ~/.ssh/id_ed25519.pub), SALIDA=<fichero>.
#
# El fichero generado lleva el hash de la contraseña: NO se sube a Git (está en .gitignore)
# y se borra después de instalar.
set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
ORIGEN="$DIR/../16-recreativa-mame/preseed-recreativa.cfg"
SALIDA="${SALIDA:-$PWD/preseed-local.cfg}"
DISCO="${1:-/dev/sda}"
CLAVE="${CLAVE:-$HOME/.ssh/id_ed25519.pub}"

[[ -r "$ORIGEN" ]] || { echo "No encuentro $ORIGEN" >&2; exit 1; }
[[ "$DISCO" =~ ^/dev/(sd[a-z]|vd[a-z]|nvme[0-9]n[0-9]|mmcblk[0-9])$ ]] \
    || { echo "Disco no válido: $DISCO (ejemplos: /dev/sda, /dev/nvme0n1)" >&2; exit 1; }
command -v openssl >/dev/null || { echo "Falta openssl (sudo apt install openssl)" >&2; exit 1; }

# Contraseña de tecnico: se pide dos veces y no aparece en pantalla ni en el historial.
read -rsp "Contraseña para el usuario tecnico (mínimo 12 caracteres): " P1; echo
read -rsp "Repítela: " P2; echo
[[ "$P1" == "$P2" ]] || { echo "No coinciden." >&2; exit 1; }
(( ${#P1} >= 12 )) || { echo "Demasiado corta: mínimo 12 caracteres." >&2; exit 1; }
HASH=$(printf '%s' "$P1" | openssl passwd -6 -stdin)
unset P1 P2

# Clave SSH (opcional). Sin ella, la recreativa solo se administra desde su consola (tty2).
LINEA_CLAVE=""
if [[ -r "$CLAVE" ]]; then
    LINEA_CLAVE=$(head -n1 "$CLAVE")
    [[ "$LINEA_CLAVE" =~ ^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp[0-9]+)\ [A-Za-z0-9+/=]+(\ [^\'\"]*)?$ ]] \
        || { echo "$CLAVE no parece una clave pública SSH." >&2; exit 1; }
else
    echo "Aviso: no hay $CLAVE; no se instala ninguna clave SSH." >&2
fi

umask 077
HASH="$HASH" DISCO="$DISCO" CLAVE_PUB="$LINEA_CLAVE" awk '
    # La contraseña en claro de VirtualBox se sustituye por el hash (una sola línea).
    /^d-i passwd\/user-password password /       { print "d-i passwd/user-password-crypted password " ENVIRON["HASH"]; next }
    /^d-i passwd\/user-password-again password / { next }
    /^d-i partman-auto\/disk string /           { print "d-i partman-auto/disk string " ENVIRON["DISCO"]; next }
    /^d-i grub-installer\/bootdev string /      { print "d-i grub-installer/bootdev string " ENVIRON["DISCO"]; next }
    # En el late_command, solo la PRIMERA aparición de CLAVE_PUBLICA_SSH: la segunda es el filtro de grep,
    # que descarta la línea si no se ha puesto ninguna clave.
    /^d-i preseed\/late_command / && ENVIRON["CLAVE_PUB"] != "" {
        i = index($0, "CLAVE_PUBLICA_SSH")
        $0 = substr($0, 1, i - 1) ENVIRON["CLAVE_PUB"] substr($0, i + length("CLAVE_PUBLICA_SSH"))
    }
    { print }
' "$ORIGEN" > "$SALIDA"

# Comprobaciones del resultado
# $6$ = hash SHA-512; va entre comillas simples a propósito (texto literal, sin expandir)
# shellcheck disable=SC2016
grep -qF 'd-i passwd/user-password-crypted password $6$' "$SALIDA" || { echo "Fallo al poner la contraseña" >&2; exit 1; }
! grep -q '@@VBOX' "$SALIDA" || { echo "Quedan marcadores de VirtualBox" >&2; exit 1; }
grep -q "^d-i partman-auto/disk string $DISCO\$" "$SALIDA" || { echo "Fallo al poner el disco" >&2; exit 1; }

echo "Generado $SALIDA (permisos 600)."
echo "  Disco:      $DISCO  (¡se BORRA entero al instalar!)"
if [[ -n "$LINEA_CLAVE" ]]; then echo "  Clave SSH:  ${LINEA_CLAVE##* }"; else echo "  Clave SSH:  ninguna"; fi
echo "Guarda la contraseña en KeePassXC. Borra $SALIDA después de instalar."
