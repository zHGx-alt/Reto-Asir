#!/usr/bin/env python3
"""Prueba guiada del arcade stick (tarea 50) en Linux, sin instalar nada.

    python3 probar-stick.py

Con la placa conectada y el firmware subido (./subir.sh), va pidiendo que pulses cada botón y muevas la
palanca, comprueba lo que llega por USB (/dev/input/jsN) y prueba los comandos del puerto serie
(VER, MAP, INV, RESET). Al final guarda el resultado en evidencias/prueba-stick-<fecha>.txt.
"""
import datetime
import glob
import os
import select
import struct
import subprocess
import sys
import time

NUM_BOTONES = 4
ESPERA = 15            # segundos para cada acción
LEJOS = 16000          # eje "a tope" (el kernel da de -32767 a 32767)
CENTRO = 8000          # eje "en el centro"
JS_BOTON, JS_EJE, JS_INICIAL = 0x01, 0x02, 0x80

resultados = []


def apunta(nombre, ok, detalle=""):
    resultados.append((nombre, ok, detalle))
    print(f"   {'OK   ' if ok else 'FALLO'} {nombre}" + (f" ({detalle})" if detalle else ""))


# ---------- Mando (joystick HID) ----------

def buscar_mando():
    for js in sorted(glob.glob("/dev/input/js*")):
        nombre = open(f"/sys/class/input/{os.path.basename(js)}/device/name").read().strip()
        if "arduino" in nombre.lower() or "leonardo" in nombre.lower():
            return js, nombre
    return None, None


class Mando:
    def __init__(self, ruta):
        self.f = open(ruta, "rb", buffering=0)
        self.botones = {}
        self.ejes = {}
        self.leer(0.5)  # estado inicial que manda el kernel al abrir

    def leer(self, tiempo):
        fin = time.time() + tiempo
        while (resto := fin - time.time()) > 0:
            if not select.select([self.f], [], [], resto)[0]:
                break
            _, valor, tipo, num = struct.unpack("IhBB", self.f.read(8))
            if tipo & ~JS_INICIAL == JS_BOTON:
                self.botones[num] = valor
            elif tipo & ~JS_INICIAL == JS_EJE:
                self.ejes[num] = valor

    def esperar(self, condicion, tiempo=ESPERA):
        fin = time.time() + tiempo
        while time.time() < fin:
            self.leer(0.05)
            if condicion():
                return True
        return False

    def pulsados(self):
        return sorted(b + 1 for b, v in self.botones.items() if v)

    def x(self):
        return self.ejes.get(0, 0)

    def y(self):
        return self.ejes.get(1, 0)

    def centrado(self):
        return abs(self.x()) < CENTRO and abs(self.y()) < CENTRO


def probar_botones(m, mapa=None):
    """mapa: botón físico -> botón HID esperado (por defecto, el mismo número)."""
    for fisico in range(1, NUM_BOTONES + 1):
        esperado = (mapa or {}).get(fisico, fisico)
        input(f"\n>> Pulsa y MANTÉN el botón {fisico} (pin {fisico + 1}) y dale a Enter con la otra mano... ")
        m.leer(0.3)
        ok = m.pulsados() == [esperado]
        apunta(f"Botón físico {fisico} -> HID {esperado}", ok, f"llegan pulsados: {m.pulsados() or 'ninguno'}")
        print("   Suéltalo...")
        apunta(f"Botón {fisico} se suelta", m.esperar(lambda: not m.pulsados()))


def probar_palanca(m):
    pruebas = [("ARRIBA", "A2", lambda: m.y() < -LEJOS), ("ABAJO", "A3", lambda: m.y() > LEJOS),
               ("IZQUIERDA", "A4", lambda: m.x() < -LEJOS), ("DERECHA", "A5", lambda: m.x() > LEJOS),
               ("ARRIBA-DERECHA (diagonal)", "A2+A5", lambda: m.y() < -LEJOS and m.x() > LEJOS)]
    for direccion, pin, cond in pruebas:
        print(f"\n>> Mueve la palanca a {direccion} ({pin}) y mantenla")
        apunta(f"Palanca {direccion}", m.esperar(cond), f"X={m.x()} Y={m.y()}")
        print("   Suéltala...")
        apunta(f"Palanca vuelve al centro tras {direccion}", m.esperar(m.centrado))


# ---------- Puerto serie ----------

class Serie:
    def __init__(self, ruta):
        subprocess.run(["stty", "-F", ruta, "9600", "raw", "-echo"], check=True)
        self.fd = os.open(ruta, os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
        time.sleep(1)
        self.leer(0.5)

    def leer(self, tiempo):
        texto, fin = b"", time.time() + tiempo
        while (resto := fin - time.time()) > 0:
            if select.select([self.fd], [], [], resto)[0]:
                try:
                    texto += os.read(self.fd, 512)
                except BlockingIOError:
                    pass
        return texto.decode(errors="replace")

    def orden(self, texto):
        os.write(self.fd, (texto + "\n").encode())
        return self.leer(1.0)


def main():
    print("=== Prueba del arcade stick (4 botones + palanca) ===")
    ruta_js, nombre = buscar_mando()
    if not ruta_js:
        sys.exit("No se ve el mando: conéctalo, sube el firmware con ./subir.sh y vuelve a probar.")
    apunta("El PC lo reconoce como mando", True, f"{ruta_js}: {nombre}")
    m = Mando(ruta_js)

    print("\n--- 1. En reposo (no toques nada) ---")
    m.leer(1)
    apunta("Sin tocar: ningún botón pulsado", not m.pulsados(), f"{m.pulsados() or 'ninguno'}")
    apunta("Sin tocar: palanca en el centro", m.centrado(), f"X={m.x()} Y={m.y()}")

    print("\n--- 2. Botones ---")
    probar_botones(m)

    print("\n--- 3. Palanca ---")
    if input("\n¿Tienes la palanca conectada? (s/n) ").strip().lower().startswith("s"):
        probar_palanca(m)
    else:
        apunta("Palanca", True, "no conectada: se prueba cuando llegue (los ejes se quedan en el centro)")

    print("\n--- 4. Puerto serie (mapeo en EEPROM) ---")
    puertos = sorted(glob.glob("/dev/ttyACM*"))
    if not puertos:
        apunta("Puerto serie", False, "no hay /dev/ttyACM*")
    elif not os.access(puertos[0], os.W_OK):
        apunta("Puerto serie", False, f"sin permiso en {puertos[0]}: sudo usermod -aG dialout $USER y volver a entrar")
    else:
        s = Serie(puertos[0])
        r = s.orden("VER")
        apunta("VER responde", "Configuracion" in r, r.strip().splitlines()[0] if r.strip() else "sin respuesta")
        r = s.orden("MAP 1 3")
        apunta("MAP 1 3 aceptado", "OK" in r, r.strip())
        print("   Ahora el botón físico 1 debe salir como el 3:")
        probar_botones(m, mapa={1: 3})
        r = s.orden("INV X")
        apunta("INV X cambia el eje", "invertido" in r, r.strip())
        s.orden("INV X")
        r = s.orden("RESET")
        apunta("RESET vuelve a los valores por defecto (sin guardar)", "OK" in r, r.strip())
        print("\n   GUARDAR + desenchufar se prueba a mano (ver README): así no se toca la EEPROM sin querer.")

    # Informe
    fallos = [r for r in resultados if not r[1]]
    fecha = datetime.datetime.now().strftime("%Y-%m-%d_%H%M")
    os.makedirs(os.path.join(os.path.dirname(os.path.abspath(__file__)), "evidencias"), exist_ok=True)
    salida = os.path.join(os.path.dirname(os.path.abspath(__file__)), "evidencias", f"prueba-stick-{fecha}.txt")
    with open(salida, "w") as f:
        f.write(f"Prueba del arcade stick · {fecha} · {nombre} ({ruta_js})\n\n")
        for n, ok, d in resultados:
            f.write(f"{'OK   ' if ok else 'FALLO'} {n}" + (f" ({d})" if d else "") + "\n")
        f.write(f"\nTotal: {len(resultados) - len(fallos)} OK, {len(fallos)} FALLO\n")
    print(f"\n=== {len(resultados) - len(fallos)} OK, {len(fallos)} FALLO · guardado en {salida} ===")
    sys.exit(1 if fallos else 0)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nCancelado.")
