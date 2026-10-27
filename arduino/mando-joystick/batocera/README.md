# El stick en Batocera

`es_input.cfg` es la configuración del stick para EmulationStation (el menú de Batocera). Así no hay que pasar por
*Configure a controller*. Se copia a la recreativa y se reinicia el menú:

```bash
scp -P 2225 es_input.cfg root@<recreativa>:/userdata/system/configs/emulationstation/es_input.cfg
ssh -p 2225 root@<recreativa> batocera-es-swissknife --restart
```

| Stick | Batocera |
|---|---|
| Palanca | Cruceta (arriba, abajo, izquierda, derecha) |
| Botón 1 (pin 2) | A: entrar / disparar |
| Botón 2 (pin 3) | B: atrás |
| Botón 3 (pin 4) | Select (moneda) y Hotkey |
| Botón 4 (pin 5) | Start |

Salir de un juego: botón 3 + botón 4 (Hotkey + Start), o Esc en el teclado.

El `deviceGUID` (`03000000412300003680000001010000`) es el que da SDL a una Leonardo (`sdl2-jstest --list` en Batocera).
Probado el 27/10/2026 en la VM `Batocera` con el stick pasado por USB: llegan los 4 botones y las 4 direcciones.
