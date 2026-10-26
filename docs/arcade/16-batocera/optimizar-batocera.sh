#!/bin/sh
# Tarea 51 · Endurece y aligera Batocera para la recreativa (1 núcleo, 1 GB). Ejecutar como root:
#   sh optimizar-batocera.sh
# La contraseña de root NO va en este script. Después, a mano (no queda en el historial ni en `ps` mucho tiempo):
#   read -rs P && batocera-config setRootPassword "$P"; unset P ; reboot
# (sin argumento genera una de solo 8 caracteres; con la seguridad desactivada no hace nada)
set -e
S=batocera-settings-set

# --- Seguridad ---
$S system.security.enabled 1     # root deja de usar la contraseña de fábrica "linux" (también la de Samba)

# --- Lo que la recreativa no usa ---
$S kodi.enabled 0                # centro multimedia
$S kodi.atstartup 0
$S splash.screen.enabled 0       # vídeo de arranque: retrasa la llegada al menú
$S splash.screen.sound 0
$S audio.bgmusic 0               # música de fondo del menú: CPU en un único núcleo
$S controllers.bluetooth.enabled 0
$S controllers.ps3.enabled 0     # mandos de PS3 por Bluetooth
$S wifi.enabled 0                # la VM va por cable; en el equipo real se activa para la Wi-Fi de invitados

# --- Memoria ---
batocera-services enable zramswap   # swap comprimida en RAM: margen cuando MAME y el menú pasan de 1 GB
batocera-services start zramswap || true

# --- Lo que NO se toca, a propósito ---
# updates.enabled: Batocera no se actualiza sola, solo avisa; se deja para no perder parches de seguridad.
# SSH: sirve para administrar; con la seguridad activada ya no entra nadie con "linux".

echo "Hecho. Falta: poner la contraseña de root (ver cabecera) y reiniciar."
