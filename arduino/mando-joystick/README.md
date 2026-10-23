# Mando arcade (firmware HID)

Firmware del arcade stick de la recreativa para la placa **Keyestudio Leonardo (KS0248)**, compatible con Arduino Leonardo (ATmega32U4). El mando se conecta por USB como un joystick HID estándar, sin drivers. El mapeo de botones se puede cambiar por el puerto serie y se guarda en la EEPROM.

Tareas relacionadas en el [backlog](../../docs/gestion/backlog-kanban.csv): #19 (montaje), #20 (firmware), #50 (prueba en físico) y #21 (pruebas con emuladores).

## Estado

| Parte | Estado |
|---|---|
| Firmware HID (2 ejes, 6 botones físicos → 8 HID) | Hecho, compila |
| Esquema de conexiones | [esquema-conexiones.svg](esquema-conexiones.svg) |
| Palanca | Pendiente de conseguir; mientras, los ejes se quedan en el centro |
| Mapeo configurable guardado en EEPROM | Hecho, compila |
| Comandos por puerto serie | Hecho, compila |
| **Prueba en la placa real** | **Pendiente (tarea #50, Adrian)** |
| Pruebas con MAME y otro emulador | Pendiente (tarea #21) |

Hasta ahora solo se ha comprobado que compila (`pio run`: Flash 37 %, RAM 17 %). No se ha ejecutado en ninguna placa.

## Conexiones

![Esquema de conexiones](esquema-conexiones.svg)

Cada botón arcade trae dos cables: **rojo** y **negro**. Son las dos patas del microswitch, así que no tienen polaridad, pero se sigue este criterio para que quede ordenado:

| Elemento | Cable | Va a |
|---|---|---|
| Botón 1 (rojo) | rojo | pin 2 |
| Botón 2 (azul) | rojo | pin 3 |
| Botón 3 (rojo) | rojo | pin 4 |
| Botón 4 (azul) | rojo | pin 5 |
| Botón 5 (azul) | rojo | pin 6 |
| Botón 6 (azul) | rojo | pin 7 |
| Los 6 botones | negro | fila − (azul) de la protoboard |
| Fila − de la protoboard | — | GND del Leonardo |
| Palanca analógica (opcional) | VRx / VRy / +5V / GND | A0 / A1 / 5V / GND |

- Sin resistencias: el código activa la resistencia interna de cada pin (`INPUT_PULLUP`).
- Los cables que acaban en **conector blanco JST** no entran en la placa ni en la protoboard: se mete un cable dupont macho en cada agujero del conector.
- Algunas protoboards largas tienen la fila − **cortada por la mitad**. En ese caso, todos los negros en la misma mitad o un puente entre las dos.
- No usar los pines 0 y 1 (RX/TX).
- Si un botón trae 4 patas, dos son del LED. Los cables van a las del microswitch.
- Cuando haya palanca, se pone `USAR_EJES = true` al principio del sketch. Sin ella, A0 y A1 quedan al aire y los ejes se moverían solos.

## Compilar y subir

### Arduino IDE

1. Descargar el ZIP de la librería desde <https://github.com/MHeironimus/ArduinoJoystickLibrary> (*Code → Download ZIP*). No está en el gestor de librerías.
2. *Programa → Incluir librería → Añadir biblioteca .ZIP* y elegir el ZIP.
3. Abrir [mando_joystick/mando_joystick.ino](mando_joystick/mando_joystick.ino).
4. *Herramientas → Placa → Arduino Leonardo* y el puerto `/dev/ttyACM0` (en Windows, `COMx`).
5. *Subir*. Si no encuentra la placa al subir, pulsar el botón **RESET** de la placa justo cuando aparezca "Subiendo…".

### PlatformIO

Desde esta carpeta (VS Code o CLI). Usa el mismo `.ino`:

```bash
pio run -t upload
```

La librería `mheironimus/Joystick` se descarga sola (está en [platformio.ini](platformio.ini)).

## Configuración por puerto serie

Abre el monitor serie a 9600 baudios. En el Arduino IDE, *Herramientas → Monitor serie* con el fin de línea en "Nueva línea". Con PlatformIO:

```bash
pio device monitor -b 9600
```

Los botones se numeran desde 1.

| Comando | Qué hace |
|---|---|
| `VER` | Muestra la configuración actual |
| `MAP <fisico> <hid>` | Asigna un botón físico a un botón HID (1–8). Ej.: `MAP 1 5` |
| `INV X` / `INV Y` | Invierte un eje (otra vez lo deja normal) |
| `ZM <0-200>` | Zona muerta del stick alrededor del centro |
| `GUARDAR` | Guarda la configuración en la EEPROM |
| `CARGAR` | Descarta los cambios y recarga la EEPROM |
| `RESET` | Vuelve a los valores por defecto (sin guardar) |

Los cambios se aplican al momento, pero se pierden al desenchufar si no se hace `GUARDAR`.

**Valores por defecto:** cada botón físico sale como el HID del mismo número (1 → 1 … 6 → 6), ejes sin invertir, zona muerta 20.

Al arrancar se lee la EEPROM. Si está vacía o los datos no son válidos (no coincide el número de control, la versión o el checksum), se usan los valores por defecto.

## Pendiente: prueba en físico (tarea #50)

Responsable: **Adrian**. Revisa: Eneko.P. Necesita el stick montado (#19).

Para cada punto, guardar captura o foto como evidencia.

- [ ] Subir el firmware a la placa sin errores.
- [ ] El PC lo reconoce como mando: `jstest /dev/input/js0` en Linux o `joy.cpl` en Windows.
- [ ] Sin palanca (`USAR_EJES = false`): los ejes se quedan quietos en el centro.
- [ ] Cada uno de los 6 botones se marca al pulsarlo (botón 1 = pin 2 … botón 6 = pin 7) y se suelta al soltarlo.
- [ ] El monitor serie responde a `VER`.
- [ ] `MAP 1 3`: el botón físico 1 pasa a salir como botón 3 y el 1 deja de marcarse.
- [ ] `INV X` cambia a "invertido" en `VER` (el efecto en el eje solo se ve con palanca).
- [ ] Con palanca (`USAR_EJES = true`): los ejes van de 0 a 1023 y se quedan quietos en el centro con la zona muerta.
- [ ] `GUARDAR`, desenchufar, volver a enchufar y `VER`: el cambio se mantiene.
- [ ] `RESET` + `GUARDAR` deja los valores por defecto.

Si todo pasa, la tarea #20 se marca como *Hecho* y se pasa a las pruebas con MAME y otro emulador (#21).
