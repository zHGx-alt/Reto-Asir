# Mando arcade (firmware HID)

Firmware del arcade stick de la recreativa para la placa **Keyestudio Leonardo (KS0248)**, compatible con Arduino Leonardo (ATmega32U4). El mando se conecta por USB como un joystick HID estándar, sin drivers. El mapeo de botones se puede cambiar por el puerto serie y se guarda en la EEPROM.

Tareas relacionadas en el [backlog](../../docs/gestion/backlog-kanban.csv): #19 (montaje), #20 (firmware), #50 (prueba en físico) y #21 (pruebas con emuladores).

## Estado

| Parte | Estado |
|---|---|
| Firmware HID (2 ejes y 4 botones) | Hecho, compila. 4 botones por indicación del profesor (26/10) |
| Palanca de arcade (4 microinterruptores) | Hecho. El 26/10 se quitan el modo analógico, la zona muerta y el modo `NINGUNA`: la palanca presupuestada es digital |
| Esquema de conexiones | [esquema-conexiones.svg](esquema-conexiones.svg), con 4 botones y la palanca (26/10) |
| Palanca | Pendiente de comprar: Sanwa JLF-TP-8YT, ya en el presupuesto ([tarea 10](../../docs/hardware/10-presupuesto-hardware.md#12-elementos-que-faltaban-en-el-presupuesto)). Sin ella, los ejes se quedan en el centro |
| Mapeo configurable guardado en EEPROM | Hecho, compila |
| Comandos por puerto serie | Hecho, compila |
| **Prueba en la placa real** | **Pendiente (tarea #50, Adrian)** |
| Pruebas con MAME y otro emulador | Pendiente (tarea #21) |

Hasta ahora solo se ha comprobado que compila (`pio run` del 26/10, con 4 botones y solo palanca digital: Flash 37,4 %, RAM 17,4 %). No se ha ejecutado en ninguna placa.

## Conexiones

![Esquema de conexiones](esquema-conexiones.svg)

Cada botón arcade trae dos cables: **rojo** y **negro**. Son las dos patas del microswitch, así que no tienen polaridad, pero se sigue este criterio para que quede ordenado:

| Elemento | Cable | Va a |
|---|---|---|
| Botón 1 (rojo) | rojo | pin 2 |
| Botón 2 (azul) | rojo | pin 3 |
| Botón 3 (rojo) | rojo | pin 4 |
| Botón 4 (azul) | rojo | pin 5 |
| Los 4 botones | negro | fila − (azul) de la protoboard |
| Fila − de la protoboard | — | GND del Leonardo |
| **Palanca de arcade** | izquierda / derecha / abajo / arriba / común (cable blanco) | A2 / A3 / A4 / A5 / GND |

- Sin resistencias: el código activa la resistencia interna de cada pin (`INPUT_PULLUP`).
- Los cables que acaban en **conector blanco JST** no entran en la placa ni en la protoboard: se mete un cable dupont macho en cada agujero del conector.
- Algunas protoboards largas tienen la fila − **cortada por la mitad**. En ese caso, todos los negros en la misma mitad o un puente entre las dos.
- No usar los pines 0 y 1 (RX/TX).
- Si un botón trae 4 patas, dos son del LED. Los cables van a las del microswitch.
- **Qué palanca:** una palanca de arcade normal (Sanwa, Zippy, Seimitsu…) **no es un potenciómetro**: son 4 microinterruptores, uno por dirección. Es la que se ha presupuestado y la única que lee el firmware. Cada microinterruptor tiene dos patas: una a su pin (A2-A5) y la otra a GND. **Ojo con el común:** en la palanca montada es el cable **blanco**; si se pincha en A2-A5 y una dirección en GND, solo funciona una dirección (pasó en la prueba del 27/10). El orden de las direcciones se ajusta en `PIN_ARRIBA`…`PIN_DERECHA` del `.ino`, sin recablear (en las Sanwa, el conector de 5 cables trae un común). Si es una palanca de 8 direcciones, las diagonales salen solas al cerrarse dos microinterruptores a la vez.
- Las palancas analógicas (de potenciómetros, como las de los mandos de consola) no están soportadas: no hacen falta para un arcade y complicaban el firmware.
- **Moneda y Start:** de los 4 botones, el 3 y el 4 se asignan en MAME a Moneda y Start, y el 1 y el 2 quedan para jugar (los juegos instalados usan como mucho 2 botones de disparo). Cómo asignarlos: [STICK-ARDUINO.md](../../docs/arcade/16-recreativa-mame/STICK-ARDUINO.md#moneda-y-start).

## Compilar y subir

### En un paso (Linux, recomendado)

Conecta la placa por USB y, desde esta carpeta:

```bash
./subir.sh
```

Compila, sube y avisa de lo que falte. La primera vez saca `arduino-cli` del AppImage del Arduino IDE que haya en
`~/Descargas` e instala el núcleo de la Leonardo y la librería Joystick. Si hace falta, aplica también el ajuste USB
`old_scheme_first` (sin él, en algunos PC no se reconoce el bootloader; pide la contraseña del usuario y se pierde al
reiniciar el PC). Con `./subir.sh monitor`, al acabar abre el monitor serie para los comandos de la sección siguiente.

Probado el 27/10/2026 en la placa real (Keyestudio Leonardo): 10 722 bytes grabados y verificados; después el PC la ve con 4 botones, la palanca en el centro y `VER` responde. Como `arduino-cli upload` a veces llega antes que el bootloader (`butterfly_recv failed`), el script reinicia la placa en modo de carga, espera a verla (USB `2341:0036`) y graba con `avrdude`. Si el usuario se acaba de añadir a `dialout`, se relanza solo con `sg dialout`.

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
| `MAP <fisico> <hid>` | Asigna un botón físico a un botón HID (1–4). Ej.: `MAP 1 3` |
| `INV X` / `INV Y` | Invierte un eje (otra vez lo deja normal) |
| `GUARDAR` | Guarda la configuración en la EEPROM |
| `CARGAR` | Descarta los cambios y recarga la EEPROM |
| `RESET` | Vuelve a los valores por defecto (sin guardar) |

Los cambios se aplican al momento, pero se pierden al desenchufar si no se hace `GUARDAR`.

**Valores por defecto:** cada botón físico sale como el HID del mismo número (1 → 1 … 4 → 4), ejes sin invertir.

La versión de la configuración pasó a 4 al dejar 4 botones y quitar el tipo de palanca y la zona muerta (26/10): una placa con una configuración antigua guardada arranca con los valores por defecto y hay que volver a hacer los `MAP` y `GUARDAR`.

Al arrancar se lee la EEPROM. Si está vacía o los datos no son válidos (no coincide el número de control, la versión o el checksum), se usan los valores por defecto.

## Prueba guiada (Linux)

Con la placa conectada y el firmware subido:

```bash
python3 probar-stick.py
```

Sin instalar nada. Va pidiendo pulsar cada botón y mover la palanca, y comprueba lo que llega al PC
(`/dev/input/jsN`): reposo sin nada pulsado y ejes en el centro; cada botón sale con su número y se suelta;
arriba/abajo/izquierda/derecha y una diagonal llegan a tope y vuelven al centro. Después prueba por el puerto serie
`VER`, `MAP 1 3` (el botón 1 pasa a salir como el 3), `INV X` y `RESET`. No hace `GUARDAR`, para no tocar la EEPROM:
eso se prueba a mano. El resultado queda en `evidencias/prueba-stick-<fecha>.txt` (evidencia de la tarea #50).

Si la palanca aún no ha llegado, se responde "n" y esa parte se salta.

Comprobado el 26/10/2026 sin placa: se para avisando de que no ve el mando; la lectura de eventos se probó con eventos simulados.

### Ver en directo lo que llega

```bash
python3 ver-mando.py
```

Cada pulsación sale al momento (`BOTÓN 1 (pin 2) PULSADO`, `PALANCA eje X = 32767`…). Sirve para encontrar cables flojos: si un botón sale solo sin tocarlo, su cable toca GND.

## Pendiente: prueba en físico (tarea #50)

Responsable: **Adrian**. Necesita el stick montado (#19).

Para cada punto, guardar captura o foto como evidencia.

- [ ] Subir el firmware a la placa sin errores.
- [ ] El PC lo reconoce como mando: `jstest /dev/input/js0` en Linux o `joy.cpl` en Windows.
- [ ] Sin palanca: los ejes se quedan quietos en el centro.
- [ ] Cada uno de los 4 botones se marca al pulsarlo (botón 1 = pin 2 … botón 4 = pin 5) y se suelta al soltarlo.
- [ ] El monitor serie responde a `VER`.
- [ ] `MAP 1 3`: el botón físico 1 pasa a salir como botón 3 y el 1 deja de marcarse.
- [ ] `INV X` cambia a "invertido" en `VER` (el efecto en el eje solo se ve con palanca).
- [ ] Con la palanca: arriba → Y = 0, abajo → Y = 1023, izquierda → X = 0, derecha → X = 1023, suelta → centro; las diagonales mueven los dos ejes.
- [ ] `INV Y` con la palanca: arriba pasa a dar Y = 1023.
- [ ] `GUARDAR`, desenchufar, volver a enchufar y `VER`: el cambio se mantiene.
- [ ] `RESET` + `GUARDAR` deja los valores por defecto.

Si todo pasa, la tarea #20 se marca como *Hecho* y se pasa a las pruebas con MAME y otro emulador (#21).
