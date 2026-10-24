# Mando arcade (firmware HID)

Firmware del arcade stick de la recreativa para la placa **Keyestudio Leonardo (KS0248)**, compatible con Arduino Leonardo (ATmega32U4). El mando se conecta por USB como un joystick HID estándar, sin drivers. El mapeo de botones se puede cambiar por el puerto serie y se guarda en la EEPROM.

Tareas relacionadas en el [backlog](../../docs/gestion/backlog-kanban.csv): #19 (montaje), #20 (firmware), #50 (prueba en físico) y #21 (pruebas con emuladores).

## Estado

| Parte | Estado |
|---|---|
| Firmware HID (2 ejes, hasta 8 botones físicos → 8 HID) | Hecho, compila |
| Palanca digital de arcade (4 microinterruptores) y analógica | Hecho (24/10): modo `PALANCA`, por defecto digital |
| Esquema de conexiones | [esquema-conexiones.svg](esquema-conexiones.svg), con la palanca digital (24/10) |
| Palanca | Pendiente de comprar: Sanwa JLF-TP-8YT, ya en el presupuesto ([tarea 10](../../docs/hardware/10-presupuesto-hardware.md#12-elementos-que-faltaban-en-el-presupuesto)). Sin ella, en modo digital los ejes se quedan en el centro |
| Mapeo configurable guardado en EEPROM | Hecho, compila |
| Comandos por puerto serie | Hecho, compila |
| **Prueba en la placa real** | **Pendiente (tarea #50, Adrian)** |
| Pruebas con MAME y otro emulador | Pendiente (tarea #21) |

Hasta ahora solo se ha comprobado que compila (`pio run` del 24/10, con la palanca digital y 8 botones: Flash 39,9 %, RAM 19,3 %). No se ha ejecutado en ninguna placa.

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
| Botones 7 y 8 (opcionales) | rojo | pines 8 y 9 |
| **Palanca digital de arcade** (por defecto) | arriba / abajo / izquierda / derecha / común | A2 / A3 / A4 / A5 / GND |
| Palanca analógica (alternativa) | VRx / VRy / +5V / GND | A0 / A1 / 5V / GND |

- Sin resistencias: el código activa la resistencia interna de cada pin (`INPUT_PULLUP`).
- Los cables que acaban en **conector blanco JST** no entran en la placa ni en la protoboard: se mete un cable dupont macho en cada agujero del conector.
- Algunas protoboards largas tienen la fila − **cortada por la mitad**. En ese caso, todos los negros en la misma mitad o un puente entre las dos.
- No usar los pines 0 y 1 (RX/TX).
- Si un botón trae 4 patas, dos son del LED. Los cables van a las del microswitch.
- **Qué palanca:** una palanca de arcade normal (Sanwa, Zippy, Seimitsu…) **no es un potenciómetro**: son 4 microinterruptores, uno por dirección. Es la que se ha presupuestado, y la lee el modo `DIGITAL`, que es el de por defecto. Cada microinterruptor tiene dos patas: una a su pin (A2-A5) y la otra a GND (en las Sanwa, el conector de 5 cables trae un común). Si es una palanca de 8 direcciones, las diagonales salen solas al cerrarse dos microinterruptores a la vez.
- La palanca analógica (de potenciómetros, como las de los mandos de consola) se elige con `PALANCA ANALOGICA`. Sin ella conectada, A0 y A1 quedan al aire y los ejes se moverían solos: por eso no es el modo por defecto.
- **Moneda y Start:** con 6 botones, Moneda y Start ocupan 2 y quedan 4 para jugar. Muchos juegos de lucha usan 6: con los pines 8 y 9 se pueden añadir 2 botones más sin cambiar el firmware.

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
| `ZM <0-200>` | Zona muerta de la palanca analógica alrededor del centro |
| `PALANCA DIGITAL` / `ANALOGICA` / `NINGUNA` | Tipo de palanca (sección Conexiones) |
| `GUARDAR` | Guarda la configuración en la EEPROM |
| `CARGAR` | Descarta los cambios y recarga la EEPROM |
| `RESET` | Vuelve a los valores por defecto (sin guardar) |

Los cambios se aplican al momento, pero se pierden al desenchufar si no se hace `GUARDAR`.

**Valores por defecto:** cada botón físico sale como el HID del mismo número (1 → 1 … 8 → 8), ejes sin invertir, zona muerta 20, palanca digital.

La versión de la configuración pasó de 2 a 3 al añadir los botones 7-8 y el tipo de palanca: una placa con la configuración antigua guardada arranca con los valores por defecto y hay que volver a hacer los `MAP` y `GUARDAR`.

Al arrancar se lee la EEPROM. Si está vacía o los datos no son válidos (no coincide el número de control, la versión o el checksum), se usan los valores por defecto.

## Pendiente: prueba en físico (tarea #50)

Responsable: **Adrian**. Revisa: Markel. Necesita el stick montado (#19).

Para cada punto, guardar captura o foto como evidencia.

- [ ] Subir el firmware a la placa sin errores.
- [ ] El PC lo reconoce como mando: `jstest /dev/input/js0` en Linux o `joy.cpl` en Windows.
- [ ] Sin palanca (modo `DIGITAL` por defecto, o `NINGUNA`): los ejes se quedan quietos en el centro.
- [ ] Cada uno de los 6 botones se marca al pulsarlo (botón 1 = pin 2 … botón 6 = pin 7) y se suelta al soltarlo; los botones 7 y 8 (pines 8 y 9), si se montan.
- [ ] El monitor serie responde a `VER`.
- [ ] `MAP 1 3`: el botón físico 1 pasa a salir como botón 3 y el 1 deja de marcarse.
- [ ] `INV X` cambia a "invertido" en `VER` (el efecto en el eje solo se ve con palanca).
- [ ] Con la palanca digital: arriba → Y = 0, abajo → Y = 1023, izquierda → X = 0, derecha → X = 1023, suelta → centro; las diagonales mueven los dos ejes.
- [ ] `INV Y` con la palanca digital: arriba pasa a dar Y = 1023.
- [ ] (Si hay palanca analógica) `PALANCA ANALOGICA`: los ejes van de 0 a 1023 y se quedan quietos en el centro con la zona muerta.
- [ ] `GUARDAR`, desenchufar, volver a enchufar y `VER`: el cambio se mantiene.
- [ ] `RESET` + `GUARDAR` deja los valores por defecto.

Si todo pasa, la tarea #20 se marca como *Hecho* y se pasa a las pruebas con MAME y otro emulador (#21).
