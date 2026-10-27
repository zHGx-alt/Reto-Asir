#!/usr/bin/env python3
"""Monitor en directo del stick y registro para evidencias (tarea 50). Sin instalar nada.

    python3 ver-mando.py              hasta Ctrl+C
    python3 ver-mando.py 60           durante 60 segundos

Muestra cada botón y cada dirección de la palanca que llega al PC por /dev/input/jsN. Al acabar
guarda en evidencias/entrada-stick-<fecha>.txt todo lo que ha llegado y un resumen: pulsaciones de
cada botón, direcciones vistas y pulsaciones de menos de 30 ms (un cable que toca GND a ratos).
"""
import datetime
import glob
import os
import struct
import sys
import time

NUM_BOTONES = 4
FANTASMA = 0.030      # una pulsación de verdad dura más de 30 ms
LEJOS = 16000         # eje "a tope" (el kernel da de -32767 a 32767)
JS_BOTON, JS_EJE, JS_INICIAL = 0x01, 0x02, 0x80
DIRECCIONES = {(0, -1): "IZQUIERDA", (0, 1): "DERECHA", (1, -1): "ARRIBA", (1, 1): "ABAJO"}


def buscar_mando():
    for js in sorted(glob.glob("/dev/input/js*")):
        with open(f"/sys/class/input/{os.path.basename(js)}/device/name") as f:
            nombre = f.read().strip()
        if "arduino" in nombre.lower() or "leonardo" in nombre.lower():
            return js, nombre
    sys.exit("No se ve el mando: conéctalo con un cable de datos y comprueba que sale en `ls /dev/input/js*`.")


ruta, nombre = buscar_mando()
duracion = float(sys.argv[1]) if len(sys.argv) > 1 else None
inicio = time.time()
lineas = []
pulsaciones = [0] * NUM_BOTONES
fantasmas = [0] * NUM_BOTONES
pulsado_en = [None] * NUM_BOTONES
direcciones = set()
ejes = [0, 0]


def apunta(texto):
    linea = f"{time.time() - inicio:7.3f} s  {texto}"
    lineas.append(linea)
    print(linea, flush=True)


print(f"{nombre} en {ruta}. Pulsa los botones y mueve la palanca"
      + (f" ({duracion:.0f} s)." if duracion else " (Ctrl+C para acabar).") + "\n")
f = os.open(ruta, os.O_RDONLY | os.O_NONBLOCK)
try:
    while duracion is None or time.time() - inicio < duracion:
        try:
            datos = os.read(f, 8)
        except BlockingIOError:
            time.sleep(0.005)
            continue
        ms, valor, tipo, num = struct.unpack("IhBB", datos)
        if tipo & JS_INICIAL:          # estado inicial que manda el kernel al abrir: no es una pulsación
            if tipo & ~JS_INICIAL == JS_EJE and num < 2:
                ejes[num] = valor
            continue
        ahora = ms / 1000              # marca de tiempo del kernel, más exacta que la de lectura
        if tipo == JS_BOTON and num < NUM_BOTONES:
            if valor:
                pulsaciones[num] += 1
                pulsado_en[num] = ahora
                apunta(f"BOTÓN {num + 1} (pin {num + 2}) pulsado")
            else:
                dura = ahora - pulsado_en[num] if pulsado_en[num] is not None else None
                corta = dura is not None and dura < FANTASMA
                fantasmas[num] += corta
                apunta(f"BOTÓN {num + 1} suelto" + (f" tras {dura * 1000:.0f} ms" if dura is not None else "")
                       + ("  ← demasiado corta: ¿cable suelto?" if corta else ""))
        elif tipo == JS_EJE and num < 2:
            ejes[num] = valor
            signo = -1 if valor < -LEJOS else 1 if valor > LEJOS else 0
            if signo:
                direcciones.add(DIRECCIONES[num, signo])
                apunta(f"PALANCA {DIRECCIONES[num, signo]}")
            elif abs(ejes[0]) < LEJOS and abs(ejes[1]) < LEJOS:
                apunta("PALANCA centro")
except KeyboardInterrupt:
    pass
finally:
    os.close(f)

# ---------- Resumen y evidencia ----------
segundos = time.time() - inicio
resumen = [f"Duración: {segundos:.0f} s"]
for b in range(NUM_BOTONES):
    estado = "OK" if pulsaciones[b] and not fantasmas[b] else "SIN PULSAR" if not pulsaciones[b] else "FANTASMAS"
    resumen.append(f"Botón {b + 1} (pin {b + 2}): {pulsaciones[b]} pulsaci{"ón" if pulsaciones[b] == 1 else "ones"}, {fantasmas[b]} de menos de "
                   f"{FANTASMA * 1000:.0f} ms -> {estado}")
faltan = [d for d in DIRECCIONES.values() if d not in direcciones]
resumen.append("Palanca: " + ("las 4 direcciones -> OK" if not faltan else "faltan " + ", ".join(faltan)))
todo_ok = all(pulsaciones) and not any(fantasmas) and not faltan
resumen.append("RESULTADO: " + ("todo llega bien" if todo_ok else "revisar lo marcado"))
print("\n" + "\n".join(resumen))

fecha = datetime.datetime.now()
salida = os.path.join(os.path.dirname(os.path.abspath(__file__)), "evidencias",
                      f"entrada-stick-{fecha:%Y-%m-%d-%H%M}.txt")
os.makedirs(os.path.dirname(salida), exist_ok=True)
with open(salida, "w") as g:
    g.write(f"Registro de entrada del stick · {fecha:%d/%m/%Y %H:%M} · {nombre} ({ruta})\n"
            f"Generado con ver-mando.py (tarea 50)\n\n## Resumen\n" + "\n".join(resumen)
            + "\n\n## Todo lo que llegó\n" + "\n".join(lineas) + "\n")
print(f"\nGuardado en {os.path.relpath(salida)}")
