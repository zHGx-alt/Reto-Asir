# Recreativa + arcade stick de Arduino

Qué tiene que cumplir el stick (tareas 19, 20 y 21) para funcionar con la recreativa (tarea 16).

## Lo que ya está comprobado
Se creó en la VM un mando virtual con la misma identidad USB que un **Arduino Leonardo / Pro Micro (ATmega32U4, VID 2341 / PID 8036)**,
y MAME lo detectó sin configurar nada ([`evidencias/prueba-stick-virtual.txt`](evidencias/prueba-stick-virtual.txt)):

```
Input: Adding joystick #1: LLC Arduino Leonardo (device id: 0300cb9d412300003680000001000000)
Game Controller: Got SDL joystick added event for reconnected game controller LLC Arduino Leonardo
```

- MAME tiene los mandos activados (`joystick 1`, zona muerta 0,15).
- El usuario `arcade` pertenece al grupo `input`, así que puede leer `/dev/input/event*`.
- MAME detecta el mando aunque se enchufe con MAME ya abierto.

## Cómo se comporta el firmware (tarea 20): joystick HID

**Decisión del equipo (23/10/2026): el stick se presenta como un joystick (gamepad) HID estándar**, no como un teclado. Firmware: [`arduino/mando-joystick/mando_joystick/mando_joystick.ino`](../../../arduino/mando-joystick/mando_joystick/mando_joystick.ino) (cableado y uso en [`arduino/mando-joystick/README.md`](../../../arduino/mando-joystick/README.md)), con la librería *ArduinoJoystickLibrary*.

Por qué joystick y no teclado:
- Cualquier emulador y cualquier sistema lo reconoce como **mando**, sin drivers, y en los menús de configuración de mandos aparece como tal («compatible con cualquier emulador», como pide el enunciado).
- No interfiere con el teclado: si se conecta un teclado para mantenimiento, sus teclas siguen siendo suyas.
- El **input personalizable** lo da el propio firmware: cada botón físico se asigna a un botón HID por el puerto serie (`MAP`, `INV`, `ZM`) y se guarda en la EEPROM. Además, cada emulador permite reasignar los botones del mando.
- MAME ya lo detecta con la identidad USB del Leonardo (prueba de arriba).

| Control del stick | Sale como | Acción en MAME |
|---|---|---|
| Palanca (digital de 4 microinterruptores por defecto; analógica con `PALANCA ANALOGICA`) | Ejes X e Y | Mover (jugador 1), sin configurar nada |
| Botones físicos 1 a 6 (pines 2 a 7) | Botones HID 1 a 6 (por defecto) | Botones 1 a 6, sin configurar nada |
| Botones HID 7 y 8 | Libres: se usan con `MAP` | — |

### Moneda y Start

Con un joystick, MAME asigna solo la palanca y los botones de juego; **Moneda y Start hay que asignarlos una vez**. Con 6 botones, la propuesta es usar los botones físicos 5 y 6 (los juegos instalados usan como mucho 2 botones de disparo):

- En MAME: `Tab` → *Input Settings* → *Input Assignments (general)* → *Other Controls* → *Coin 1* = botón 5 y *1 Player Start* = botón 6. MAME lo guarda en `/home/arcade/.mame/cfg/default.cfg`.
- O directamente en ese fichero, junto al `UI_SELECT` que ya crea `instalar-arcade.sh`:

```xml
<port type="COIN1">
    <newseq type="standard">KEYCODE_5 OR JOYCODE_1_BUTTON5</newseq>
</port>
<port type="START1">
    <newseq type="standard">KEYCODE_1 OR JOYCODE_1_BUTTON6</newseq>
</port>
```

Así se mantienen también las teclas `5` y `1` del teclado. Esta asignación se comprueba en la tarea 21; cuando funcione con el stick real, se añade a `instalar-arcade.sh` para que quede en la instalación.

En los menús de MAME, el **botón 1** del mando también sirve para elegir (`JOYCODE_1_BUTTON1` en `UI_SELECT`, ya configurado por `instalar-arcade.sh`).

## Conectarlo a la máquina virtual
1. **En el PC anfitrión** (solo una vez), da permiso a VirtualBox para usar USB y **cierra sesión y vuelve a entrar**:
   ```bash
   sudo usermod -aG vboxusers $USER
   ```
2. La VM `Recreativa` ya tiene el controlador USB activado y dos **filtros** que pasan el stick a la VM automáticamente:
   - `Arduino (VID 2341)`: Leonardo, Micro y placas oficiales.
   - `SparkFun Pro Micro (VID 1B4F)`: clones Pro Micro.
   Si vuestra placa tiene otro VID, mirad cuál es con `lsusb` en el anfitrión y añadid el filtro en *Configuración → USB*.
3. Enchufa el stick con la VM encendida. Dentro de la VM, compruébalo así:
   ```bash
   cat /proc/bus/input/devices | grep -A4 -i arduino
   ```

> ⚠️ Mientras el stick esté pasado a la VM, el anfitrión no lo ve. Para reprogramarlo desde el Arduino IDE,
> quítalo en la ventana de la VM (*Dispositivos → USB*) o apaga la VM.

En la **máquina física** no hace falta nada de esto: se enchufa por USB y listo.

## Prueba simulada (22/10/2026)
> Esta prueba se hizo cuando todavía se pensaba en un firmware de teclado. Demuestra que MAME, el usuario `arcade` y la VM están listos para un mando USB; la prueba con el joystick real es la tarea 21.

Dentro de la VM se creó un teclado virtual con la identidad USB del Arduino Leonardo, que mandaba las teclas previstas entonces
(`stick_teclado.py`, con `python3-evdev`). Secuencia: Salir → Botón 1 (elige Gridlee) → Botón 1 (quita el aviso) → Moneda → Start → Palanca → Botón 1.
Resultado: **la partida empieza y el personaje se mueve y dispara**.

| Moneda → `CREDITS 1` | Partida con el stick simulado |
|---|---|
| ![](evidencias/07-moneda-credits-1.png) | ![](evidencias/09-partida-gridlee-stick.png) |

## Prueba de aceptación (para la tabla de pruebas, tarea 47)
| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | Encender la recreativa con el stick enchufado | MAME aparece sin tocar el teclado |
| 2 | Mover la palanca en el menú | La selección se mueve |
| 3 | Elegir Gridlee con el stick | El juego arranca |
| 4 | Pulsar Moneda y luego Start | Aparece `CREDITS 1` y empieza la partida |
| 5 | Jugar con la palanca y el botón 1 | El personaje se mueve y dispara |
| 6 | Desenchufar y volver a enchufar el stick en mitad de la partida | Sigue funcionando |
