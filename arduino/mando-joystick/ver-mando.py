#!/usr/bin/env python3
"""Monitor en directo del stick: muestra cada botón y movimiento de la palanca que llega al PC. Ctrl+C para salir."""
import struct, time
f = open('/dev/input/js0', 'rb', buffering=0)
print("Monitor del mando en directo (Ctrl+C para salir).\n")
while True:
    _, v, t, n = struct.unpack('IhBB', f.read(8))
    if t & 0x80:
        continue
    hora = time.strftime('%H:%M:%S')
    if t == 1:
        print(f"{hora}  BOTÓN {n + 1} (pin {n + 2}) {'PULSADO' if v else 'suelto'}", flush=True)
    elif t == 2:
        print(f"{hora}  PALANCA eje {'X' if n == 0 else 'Y'} = {v}", flush=True)
