#!/usr/bin/env bash
# Compila y sube el firmware del stick a la placa Leonardo con UN comando (Linux).
#   ./subir.sh            compila y sube
#   ./subir.sh monitor    después abre el monitor serie (para VER, MAP, GUARDAR...; salir con Ctrl+C)
# Usa arduino-cli: si no está instalado, lo saca del AppImage del Arduino IDE que haya en ~/Descargas.
set -euo pipefail
cd "$(dirname "$0")"

FQBN=arduino:avr:leonardo
SKETCH=mando_joystick
LIB_URL=https://github.com/MHeironimus/ArduinoJoystickLibrary
LIB_VERSION=v2.1.1   # fijada (tarea 46, S-21): la misma con la que se probó; no la rama principal
falla() { echo "ERROR: $*" >&2; exit 1; }

# 1. arduino-cli
CLI=$(command -v arduino-cli || true)
[[ -z $CLI && -x ~/.local/bin/arduino-cli ]] && CLI=~/.local/bin/arduino-cli
if [[ -z $CLI ]]; then
  IDE=$(ls ~/Descargas/arduino-ide_*_Linux_64bit.AppImage ~/Downloads/arduino-ide_*_Linux_64bit.AppImage 2>/dev/null | tail -1) \
    || falla "no hay arduino-cli ni el AppImage del Arduino IDE en ~/Descargas"
  echo "==> Sacando arduino-cli de $(basename "$IDE")"
  TMP=$(mktemp -d)
  (cd "$TMP" && "$IDE" --appimage-extract 'resources/app/lib/backend/resources/arduino-cli' >/dev/null)
  mkdir -p ~/.local/bin
  install -m 755 "$TMP"/squashfs-root/resources/app/lib/backend/resources/arduino-cli ~/.local/bin/
  rm -rf "$TMP"
  CLI=~/.local/bin/arduino-cli
fi

# 2. Núcleo de la Leonardo y librería Joystick (solo la primera vez)
"$CLI" core list | grep -q '^arduino:avr ' || { "$CLI" core update-index; "$CLI" core install arduino:avr; }
if ! "$CLI" lib list 2>/dev/null | grep -q '^Joystick '; then
  echo "==> Instalando la librería Joystick"
  ARDUINO_LIBRARY_ENABLE_UNSAFE_INSTALL=true "$CLI" lib install --git-url "$LIB_URL.git#$LIB_VERSION"
fi

# 3. Compilar
echo "==> Compilando"
"$CLI" compile --fqbn "$FQBN" "$SKETCH" | tail -2

# 4. Placa conectada
PUERTO=$(ls /dev/ttyACM* 2>/dev/null | head -1 || true)
[[ -n $PUERTO ]] || falla "no se ve la placa: conéctala por USB (con un cable de datos, no solo de carga) y vuelve a ejecutar"
[[ -w $PUERTO ]] || falla "sin permiso en $PUERTO: sudo usermod -aG dialout $USER y cierra sesión"
# En algunos PC el bootloader de la Leonardo no se reconoce al reiniciarse sin esto (se pierde al reiniciar el PC)
if [[ $(cat /sys/module/usbcore/parameters/old_scheme_first) != Y ]]; then
  echo "==> Ajuste USB para el bootloader (pide la contraseña de tu usuario)"
  echo Y | sudo tee /sys/module/usbcore/parameters/old_scheme_first >/dev/null
fi

# 5. Subir
echo "==> Subiendo a $PUERTO"
"$CLI" upload --fqbn "$FQBN" -p "$PUERTO" "$SKETCH" \
  || falla "no se pudo subir: pulsa RESET en la placa justo al ver 'Subiendo' (o vuelve a ejecutar)"
echo "==> Hecho. Comprueba el mando con: jstest /dev/input/js0"

# 6. Monitor serie (opcional)
if [[ ${1:-} == monitor ]]; then
  sleep 2
  PUERTO=$(ls /dev/ttyACM* | head -1)
  echo "==> Monitor serie en $PUERTO (escribe VER y Enter; salir con Ctrl+C)"
  "$CLI" monitor -p "$PUERTO" -c baudrate=9600
fi
