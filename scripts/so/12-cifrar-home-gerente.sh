#!/bin/bash
# Tarea 12 · cifra /home/gerente con fscrypt (ext4) usando la contraseña de inicio de sesión de gerente
set -euo pipefail
[ "$(id -u)" = 0 ] || { echo "Lánzalo con sudo"; exit 1; }
who | grep -q '^gerente ' && { echo "Cierra antes la sesión de gerente"; exit 1; }
OUT=${1:-/root/ubu-09-fscrypt-home-gerente.txt}   # ruta de la evidencia (sin secretos)
apt-get update -q && apt-get install -y -q fscrypt libpam-fscrypt
DEV=$(findmnt -no SOURCE -T /home); MNT=$(findmnt -no TARGET -T /home)
tune2fs -l "$DEV" | grep -q 'features:.*encrypt' || tune2fs -O encrypt "$DEV"
[ -e /etc/fscrypt.conf ] || fscrypt setup --quiet
[ -d "$MNT/.fscrypt" ] || fscrypt setup "$MNT" --quiet
if fscrypt status /home/gerente 2>/dev/null | grep -q 'is encrypted'; then
  echo "/home/gerente ya estaba cifrado"
else
  mv /home/gerente /home/gerente.sin-cifrar
  install -d -o gerente -g gerente -m 700 /home/gerente
  echo; echo ">>> Ahora escribe la contraseña de INICIO DE SESIÓN de gerente (KeePassXC)"; echo
  if ! fscrypt encrypt /home/gerente --user=gerente --source=pam_passphrase; then
    rmdir /home/gerente; mv /home/gerente.sin-cifrar /home/gerente
    echo "No se ha cifrado (¿contraseña de gerente incorrecta?). /home/gerente queda como estaba."; exit 1
  fi
  cp -a /home/gerente.sin-cifrar/. /home/gerente/
  rm -rf /home/gerente.sin-cifrar
fi
{ echo "# Tarea 12 · Ubuntu del gerente: /home/gerente cifrado con fscrypt ($(date '+%F %H:%M'))"
  echo; echo '$ lsblk -f'; lsblk -f
  echo; echo "\$ tune2fs -l $DEV | grep features"; tune2fs -l "$DEV" | grep -i features
  echo; echo '$ fscrypt status /home/gerente'; fscrypt status /home/gerente
  echo; echo '$ grep fscrypt /etc/pam.d/common-*'; grep -H fscrypt /etc/pam.d/common-* || true
} > "$OUT"
echo; echo "HECHO. Evidencia en $OUT"
