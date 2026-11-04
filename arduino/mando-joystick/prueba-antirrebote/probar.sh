#!/usr/bin/env bash
# Compila el firmware real en el PC con sustitutos de Arduino y prueba el antirrebote.
# Uso: bash arduino/mando-joystick/prueba-antirrebote/probar.sh
set -euo pipefail
cd "$(dirname "$0")"
salida=$(mktemp -d)
trap 'rm -rf "$salida"' EXIT
g++ -std=c++17 -Wall -Wno-unused-function -x c++ -I stubs -o "$salida/prueba" prueba.cpp
"$salida/prueba"
