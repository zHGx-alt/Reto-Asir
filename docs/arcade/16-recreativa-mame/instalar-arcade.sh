#!/usr/bin/env bash
# Tarea 16 · Instalar SO ligero y MAME con arranque directo
#
# Convierte un Debian 13 recién instalado SIN escritorio en una recreativa:
# al encender, inicia sesión solo el usuario "arcade" y abre MAME a pantalla completa.
#
# Uso:  sudo ./instalar-arcade.sh
# Se puede ejecutar varias veces sin romper nada (idempotente).
set -euo pipefail

MAME=/usr/games/mame   # Debian instala MAME aquí (fuera del PATH de sudo)
USUARIO_ARCADE="${USUARIO_ARCADE:-arcade}"
HOME_ARCADE="/home/${USUARIO_ARCADE}"

log() { printf '\n==> %s\n' "$*"; }

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta el script con sudo: sudo $0" >&2
  exit 1
fi

log "1/6 Instalando paquetes mínimos (MAME + X11 sin escritorio)"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  mame \
  xserver-xorg-core xserver-xorg-input-libinput xinit x11-xserver-utils \
  libgl1-mesa-dri \
  alsa-utils

log "2/6 Creando el usuario '${USUARIO_ARCADE}' (sin sudo y sin contraseña de acceso)"
if ! id "$USUARIO_ARCADE" &>/dev/null; then
  useradd -m -s /bin/bash "$USUARIO_ARCADE"
fi
usermod -aG audio,video,input "$USUARIO_ARCADE"
# Mínimos privilegios: la cuenta no puede iniciar sesión con contraseña (solo autologin en tty1)
passwd -l "$USUARIO_ARCADE" >/dev/null

log "3/6 Configurando el inicio de sesión automático en tty1"
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${USUARIO_ARCADE} --noclear %I \$TERM
EOF
systemctl daemon-reload
systemctl set-default multi-user.target

log "4/6 Configurando el arranque directo a MAME"
# Al iniciar sesión en tty1 se lanza X; en tty2 (Ctrl+Alt+F2) queda una consola normal para administrar.
cat > "${HOME_ARCADE}/.bash_profile" <<'EOF'
if [[ -z ${DISPLAY:-} && $(tty) == /dev/tty1 ]]; then
  exec startx -- -nocursor
fi
EOF

# X arranca solo MAME, sin gestor de ventanas. Si MAME se cierra, se vuelve a abrir.
cat > "${HOME_ARCADE}/.xinitrc" <<'EOF'
xset s off s noblank -dpms
cd "$HOME"
while true; do
  /usr/games/mame -rompath "$HOME/roms" -skip_gameinfo
  sleep 1
done
EOF

# El menú de MAME muestra solo los juegos cuyas ROMs están instaladas
mkdir -p "${HOME_ARCADE}/roms" "${HOME_ARCADE}/.mame"
if [[ ! -f "${HOME_ARCADE}/.mame/ui.ini" ]]; then
  echo "last_used_filter          Available" > "${HOME_ARCADE}/.mame/ui.ini"
fi
# Arcade stick: en los menús de MAME, el botón 1 (Ctrl / botón 1 del mando) y Start (1) también eligen, no solo Enter
mkdir -p "${HOME_ARCADE}/.mame/cfg"
if [[ ! -f "${HOME_ARCADE}/.mame/cfg/default.cfg" ]]; then
  cat > "${HOME_ARCADE}/.mame/cfg/default.cfg" <<'EOF'
<?xml version="1.0"?>
<mameconfig version="10">
    <system name="default">
        <input>
            <port type="UI_SELECT">
                <newseq type="standard">KEYCODE_ENTER OR KEYCODE_ENTER_PAD OR KEYCODE_LCONTROL OR KEYCODE_1 OR JOYCODE_1_BUTTON1</newseq>
            </port>
        </input>
    </system>
</mameconfig>
EOF
fi
chown -R "${USUARIO_ARCADE}:${USUARIO_ARCADE}" \
  "${HOME_ARCADE}/.bash_profile" "${HOME_ARCADE}/.xinitrc" "${HOME_ARCADE}/roms" "${HOME_ARCADE}/.mame"

log "5/6 Acelerando el arranque (GRUB sin espera y sin mensajes)"
if [[ -f /etc/default/grub ]]; then
  sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
  sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3"/' /etc/default/grub
  update-grub
else
  echo "No se encontró /etc/default/grub, se omite este paso."
fi

log "6/6 Comprobación"
echo "Versión de MAME: $("$MAME" -version 2>/dev/null || echo 'NO INSTALADO')"
echo "Usuario: $(id "$USUARIO_ARCADE")"
echo "Destino de arranque: $(systemctl get-default)"
echo "Carpeta de ROMs: ${HOME_ARCADE}/roms ($(find "${HOME_ARCADE}/roms" -type f | wc -l) archivos)"

cat <<EOF

Listo. Copia las ROMs (archivos .zip, sin descomprimir) en ${HOME_ARCADE}/roms
y reinicia con:  sudo reboot
EOF
