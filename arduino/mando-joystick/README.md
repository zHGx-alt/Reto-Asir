# Mando arcade (firmware HID)

Firmware del arcade stick de la recreativa para la placa **Keyestudio Leonardo (KS0248)**, compatible con Arduino Leonardo (ATmega32U4). El mando se conecta por USB como un joystick HID estándar, sin drivers. El mapeo de botones se puede cambiar por el puerto serie y se guarda en la EEPROM.

Tareas relacionadas en el [backlog](../../docs/gestion/backlog-kanban.csv): #19 (montaje), #20 (firmware), #50 (prueba en físico) y #21 (pruebas con emuladores).

## Estado

| Parte | Estado |
|---|---|
| Firmware HID (2 ejes y 4 botones) | Hecho, compila. 4 botones por indicación del profesor (26/10) |
| Palanca de arcade (4 microinterruptores) | Hecho. El 26/10 se quitan el modo analógico, la zona muerta y el modo `NINGUNA`: la palanca presupuestada es digital |
| Esquema de conexiones | [esquema-conexiones.svg](esquema-conexiones.svg), con 4 botones y la palanca (26/10) |
| Montaje (#19) | Hecho: caja con la palanca y los botones ([foto](evidencias/stick-montado-2026-10-27.webp), 27/10). La caja tiene 6 botones, pero el firmware lee 4 (pines 2 a 5): solo esos 4 llegan al PC |
| Mapeo configurable guardado en EEPROM | Hecho y probado en la placa (27/10): `MAP` + `GUARDAR` sobrevive a un reinicio |
| Comandos por puerto serie | Hecho y probado en la placa (27/10): `VER`, `MAP`, `GUARDAR` y `RESET` |
| **Prueba en la placa real** | **Hecha el 27/10** (tarea #50): botones, palanca, puerto serie y EEPROM. Ver [la prueba](#prueba-en-físico-tarea-50) |
| Pruebas con MAME y otro emulador | Hecho (tarea #21): en MAME, partida de *Gridlee* con el stick en la recreativa de 1 GB ([tarea 53](../../docs/arcade/53-recreativa-fisica/DOCUMENTACION.md), P4 y P10, 29/10); en Batocera (RetroArch), entradas comprobadas ([evtest](evidencias/batocera-evtest-2026-10-27.txt)) y partida jugada el 27/10, sin captura |

Funciona en la placa real desde el 27/10. Desde el 04/11 lleva antirrebote por software (5 ms por entrada) y ya no usa `delay(10)`; `bash prueba-antirrebote/probar.sh` compila el `.ino` en el PC y lo prueba con rebotes simulados (9 de 9 OK). El 12/11 se subió a la placa y se probó con el stick: 116 pulsaciones en 45 s, todas bien ([registro](evidencias/entrada-stick-2026-11-12-0918.txt)); ver [Antirrebote](#antirrebote-tarea-59).

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

## Configuración por puerto serie

Abre el monitor serie a 9600 baudios. En el Arduino IDE, *Herramientas → Monitor serie* con el fin de línea en "Nueva línea". Desde la terminal, `./subir.sh monitor`.

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

## Antirrebote (tarea 59)

**Por qué hace falta.** Un botón arcade o un microinterruptor de la palanca es una lámina de metal que, al cerrarse, **rebota** durante unos milisegundos: el contacto se abre y se cierra varias veces antes de quedarse quieto. El Arduino lee cada pin miles de veces por segundo, así que sin filtro una sola pulsación puede llegar al PC como dos o tres (en un juego, varios disparos o una moneda de más). El 27/10, con un cable suelto, Iker vio 21 pulsaciones fantasma del botón 3 en 20 s.

**Por qué 5 ms.** Los microinterruptores de arcade rebotan menos de 5 ms; una pulsación humana rápida dura más de 30 ms (las del 27/10, de 31 a 113 ms). Con 5 ms se filtra el rebote y la pulsación llega al PC en unos 6 ms, por debajo de un fotograma de juego (16,7 ms a 60 Hz). Antes se usaba `delay(10)`, que paraba todo el programa 10 ms en cada vuelta; ahora cada entrada lleva su propio temporizador con `millis()` y el resto sigue funcionando.


**Dónde está el código**, en [mando_joystick.ino](mando_joystick/mando_joystick.ino):

| Qué | Línea |
|---|---|
| Explicación y `ANTIRREBOTE_MS = 5` (lo que tiene que estar estable una lectura para aceptarla) | [163-173](mando_joystick/mando_joystick.ino#L163) |
| `iniciarEntradas()`: junta los 4 botones y las 4 direcciones en una sola lista de 8 entradas | [175](mando_joystick/mando_joystick.ino#L175) |
| `actualizarEntradas()`: **el antirrebote**. Por cada entrada guarda la última lectura y desde cuándo (`millis()`); solo cambia el estado cuando lleva 5 ms sin variar | [190](mando_joystick/mando_joystick.ino#L190) |
| `leerEje()` y `enviarEstado()`: usan el estado ya filtrado, no `digitalRead` directo | [208](mando_joystick/mando_joystick.ino#L208), [223](mando_joystick/mando_joystick.ino#L223) |
| `loop()`: sin `delay(10)`; envía por USB cuando cambia algo o cada 100 ms | [244](mando_joystick/mando_joystick.ino#L244) |

**La prueba simulada** está en [prueba-antirrebote/](prueba-antirrebote/): `prueba.cpp` compila el `.ino` real en el PC con sustitutos de Arduino (`stubs/`) y simula rebotes. Se lanza con `bash prueba-antirrebote/probar.sh`. El 04/11 dio 9 de 9 OK: una pulsación con rebotes cuenta 1, el ruido de 1-2 ms no pasa, la pulsación llega en 6 ms y remapear no deja botones colgados.

**La prueba en la placa (12/11).** Firmware subido con `./subir.sh` y `python3 ver-mando.py 45` pulsando cada botón y cada dirección varias veces, rápido ([registro](evidencias/entrada-stick-2026-11-12-0918.txt)). Sale bien si cada botón cuenta las pulsaciones hechas y ninguna dura menos de 30 ms:

| Control | Pulsaciones | De menos de 30 ms | Resultado |
|---|---|---|---|
| Botón 1 (pin 2) | 23 | 0 | ✅ |
| Botón 2 (pin 3) | 28 | 0 | ✅ |
| Botón 3 (pin 4) | 41 | 0 | ✅ |
| Botón 4 (pin 5) | 24 | 0 | ✅ |
| Palanca | Las 4 direcciones | — | ✅ |

La pulsación más corta duró 39 ms, así que no llega al PC ningún rebote, ni con pulsaciones muy seguidas (botones 2 y 3 alternados, unas 7 por segundo). Resultado de `ver-mando.py`: «todo llega bien». Las pruebas por control del 27 y el 30/10 se hicieron con la versión anterior (`delay(10)`), que también filtraba el rebote, aunque peor.

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

### Ver en directo lo que llega (y dejar evidencia)

```bash
python3 ver-mando.py        # hasta Ctrl+C
python3 ver-mando.py 45     # durante 45 segundos
```

Sin instalar nada. Busca el mando por su nombre, muestra cada pulsación y dirección al momento
(`BOTÓN 1 (pin 2) pulsado`, `PALANCA ARRIBA`…) y, al acabar, guarda en `evidencias/entrada-stick-<fecha>.txt`
todo lo que llegó con un resumen: pulsaciones de cada botón, si llegan las 4 direcciones y cuántas pulsaciones
duraron menos de 30 ms. Esas son las que no hace un dedo: un cable que toca GND a ratos. Si todo está bien, termina
con `RESULTADO: todo llega bien`.

## Pasar el stick entre el PC y la VM

En el PC, la VM de la recreativa tiene un filtro USB que se queda el stick en cuanto se enchufa, y MAME solo busca mandos al arrancar. Para no ir a los menús de VirtualBox:

```bash
./pasar-stick.sh pc    # el PC lo ve: ver-mando.py, probar-stick.py y el puerto serie
./pasar-stick.sh vm    # activa el filtro y reinicia la VM: MAME arranca con el stick
```

La VM es `Recreativa-Demo` por defecto; otra con `VM=Nombre ./pasar-stick.sh vm`. Probado en los dos sentidos el 12/11, al validar las tareas 5 y 12.

## Prueba en físico (tarea #50)

Hecha el 27/10/2026 con el stick montado (#19): primero Iker (subida, cableado de la palanca y Batocera) y después Adrian (registro de entrada y EEPROM).

| Comprobación | Resultado | Evidencia |
|---|---|---|
| Subir el firmware | ✅ `subir.sh` reinicia la placa, espera al bootloader y graba con avrdude: *10722 bytes of flash verified* | [prueba-placa](evidencias/prueba-placa-2026-10-27.txt), apartados 1 y 2 |
| El PC lo reconoce como mando | ✅ `2341:8036 Arduino Leonardo`, `/dev/input/js0`, joystick HID con 2 ejes y 4 botones | [prueba-placa](evidencias/prueba-placa-2026-10-27.txt), apartado 1 |
| Reposo | ✅ Ejes en el centro y nada pulsado | [prueba-placa](evidencias/prueba-placa-2026-10-27.txt), apartado 2 |
| Los 4 botones | ✅ Cada uno llega con su número y se suelta. Pulsaciones de 31 a 113 ms; ninguna de menos de 30 ms | [registro 1](evidencias/entrada-stick-2026-10-27-1124.txt), [registro 2](evidencias/entrada-stick-2026-10-27-1125.txt), [captura](evidencias/ver-mando-en-directo-2026-10-27.png) |
| Palanca | ✅ Arriba, abajo, izquierda y derecha, y vuelve al centro. Los pines se ajustaron en el `.ino` al cableado real | Los mismos registros; [prueba-placa](evidencias/prueba-placa-2026-10-27.txt), apartado 4 |
| Pulsaciones fantasma del botón 3 | ✅ Resuelta: Iker vio 21 en 20 s con el cable suelto. Con el montaje final, 45 s de registro (unos 35 sin tocar) sin ninguna | [registro 2](evidencias/entrada-stick-2026-10-27-1125.txt) |
| `VER` por el puerto serie | ✅ | [eeprom](evidencias/eeprom-2026-10-27.txt) |
| `MAP` + `GUARDAR` + reinicio + `VER` | ✅ `MAP 1 2` y `MAP 2 1` siguen después de reiniciar la placa (el kernel la ve pasar por el bootloader, `2341:0036`, y volver) | [eeprom](evidencias/eeprom-2026-10-27.txt) |
| `RESET` + `GUARDAR` | ✅ Vuelven los valores por defecto (la placa queda así) | [eeprom](evidencias/eeprom-2026-10-27.txt) |
| Batocera | ✅ La reconoce (`sdl2-jstest`) y `evtest` recibe los 4 botones y los ejes | [evtest](evidencias/batocera-evtest-2026-10-27.txt), [es_input.cfg](batocera/es_input.cfg) |

**Repaso del 30/10 con `probar-stick.py`** ([prueba-stick](evidencias/prueba-stick-2026-10-30_0744.txt)): 28 OK y 5 FALLO, pero los fallos no son del mando:

- Los botones se pulsaron sin saber qué número tiene cada uno (en el stick montado no se ven los pines), así que el script pedía «el 2» y se pulsaba otro. Lo que importa sí se cumple: cada pulsación llega como **un solo** botón y los 4 son distintos.
- **`MAP 1 3` pulsando: ✅** el botón que antes llegaba como 1 pasa a llegar como 3.
- La palanca vuelve a dar las 4 direcciones y la diagonal.
- El script tenía un fallo: miraba el botón 200 ms después de la pulsación y un toque rápido ya estaba suelto. Corregido el 30/10 (ahora apunta qué botón se pulsa).

**Sin comprobar:** `INV X` / `INV Y` moviendo la palanca. El script solo comprueba que la placa responde «invertido».

Nota: la lista original hablaba de ejes de 0 a 1023. El kernel los entrega de −32767 a 32767 (en `evtest`, de 0 a 65535), así que eso es lo que se mide.

## Pruebas por control

Cada control del stick, probado en la placa real con la versión anterior al antirrebote nuevo (`delay(10)`). Registros del 27/10 ([1](evidencias/entrada-stick-2026-10-27-1124.txt), [2](evidencias/entrada-stick-2026-10-27-1125.txt)) y repaso del 30/10 con `probar-stick.py` ([prueba-stick](evidencias/prueba-stick-2026-10-30_0744.txt)). El 12/11 se repitieron botones y palanca con el antirrebote nuevo y salieron igual ([registro](evidencias/entrada-stick-2026-11-12-0918.txt), [tabla](#antirrebote-tarea-59)).

| Control | Pin | Llega al PC como | Se suelta | En MAME | En Batocera | Resultado |
|---|---|---|---|---|---|---|
| Reposo (nada pulsado) | — | Ejes X=0, Y=0, ningún botón | — | — | ✅ | ✅ |
| Botón 1 | 2 | Botón HID 1 | ✅ | Disparo 1 | ✅ `evtest` | ✅ |
| Botón 2 | 3 | Botón HID 2 | ✅ | Disparo 2 | ✅ | ✅ |
| Botón 3 | 4 | Botón HID 3 | ✅ | Moneda | ✅ | ✅ (sin pulsaciones fantasma con el montaje final: 45 s de registro) |
| Botón 4 | 5 | Botón HID 4 | ✅ | Start | ✅ | ✅ |
| Palanca arriba | A5 | Y = −32767 | ✅ vuelve a 0 | ✅ | ✅ | ✅ |
| Palanca abajo | A4 | Y = 32767 | ✅ | ✅ | ✅ | ✅ |
| Palanca izquierda | A2 | X = −32767 | ✅ | ✅ | ✅ | ✅ |
| Palanca derecha | A3 | X = 32767 | ✅ | ✅ | ✅ | ✅ |
| Diagonal (arriba-derecha) | A5 + A3 | X = 32767, Y = −32767 | ✅ | ✅ | — | ✅ |
| Remapeo `MAP 1 3` | serie | El botón 1 llega como 3 | — | — | — | ✅ (y sigue tras reiniciar con `GUARDAR`) |

- **Duración de las pulsaciones:** de 31 a 113 ms; ninguna de menos de 30 ms (sin rebotes que lleguen al PC).
- **Numeración:** el 30/10 los botones se pulsaron sin saber qué número tenía cada uno (en la caja no se ven los pines), de ahí los 5 «FALLO» del registro: cada pulsación llegó como **un solo** botón y los cuatro son distintos, que es lo que se comprueba.
- **En MAME:** partida de *Gridlee* con el stick en la recreativa de 1 núcleo y 1 GB ([tarea 53](../../docs/arcade/53-recreativa-fisica/DOCUMENTACION.md), P4 y P10, 29/10). **En Batocera (RetroArch):** `evtest` recibe los 4 botones y los ejes ([evtest](evidencias/batocera-evtest-2026-10-27.txt)) y se jugó una partida (27/10, sin captura).
- **Sin comprobar:** `INV X` / `INV Y` moviendo la palanca (solo que la placa responde «invertido») y el antirrebote nuevo en la placa (arriba).

## Componentes y presupuesto

Precios de referencia consultados el 10/11/2026 (IVA incluido, sin envío). La palanca es la del [presupuesto de la tarea 10](../../docs/hardware/10-presupuesto-hardware.md#12-elementos-que-faltaban-en-el-presupuesto); la placa y los botones no tenían precio.

| Componente | Modelo | Uds. | Precio unidad | Subtotal | Fuente |
|---|---|---:|---:|---:|---|
| Placa | Keyestudio Leonardo R3 (KS0248), ATmega32U4, con cable USB | 1 | 18,73 € | 18,73 € | [abcescolar.pt](https://abcescolar.pt/en/products/placa-controladora-arduino-leonardo-r3-keyestudio) (agotada ese día; en otras tiendas, hasta 35 €) |
| Palanca | Sanwa JLF-TP-8YT, 4 microinterruptores | 1 | 22,73 € | 22,73 € | Tarea 10, sección 12 |
| Botones | 30 mm tipo Sanwa OBSF-30 (la caja tiene 6; el firmware lee 4) | 6 | 2,19 € | 13,14 € | [Arcadexpress](https://www.arcadexpress.com/en/buttons/104-boton-arcade-sanwa-obsf-30.html) |
| Cableado | Protoboard, cables dupont macho-macho y terminales de los botones | 1 | — | — | Material del aula |
| Caja | Caja del stick con los agujeros de la palanca y los 6 botones | 1 | — | — | Material del aula |
| **Total con precio** | | | | **54,60 €** | |

Sin resistencias ni condensadores: el firmware usa la resistencia interna de cada pin (`INPUT_PULLUP`) y el antirrebote es por software.

## Por qué un microcontrolador y no un encoder USB comercial

El stick es un **sistema embebido**: un microcontrolador dentro del mando, programado para una sola tarea. El análisis completo, con el resto de tecnologías habilitadoras del reto, está en la [tarea 58, sección 5](../../docs/digitalizacion/58-tecnologias-habilitadoras.md#5-sistemas-embebidos-e-iot-arduino).

| Opción | Precio de referencia | Ventajas | Inconvenientes |
|---|---|---|---|
| **Arduino Leonardo (ATmega32U4)** ✅ | 54,60 € con la palanca y los botones | USB nativo: el PC lo ve como mando sin drivers; **remapeo sin reprogramar** guardado en la EEPROM; antirrebote ajustable; firmware propio, comentado y en Git; ampliable (luces, contador de partidas, Wi-Fi con otra placa) | Hay que programarlo y cablearlo |
| Encoder USB «zero delay» (kit con palanca y botones) | Unos 20 € el kit de 1 jugador con 10 botones ([Arcadexpress](https://www.arcadexpress.com/en/joystick-kits/149-287-kit-1-jugador-americano-joystick-10-botones-usb.html)) | Más barato y se conecta y funciona | Mapeo fijo de fábrica; no se puede cambiar el antirrebote ni guardar configuración; caja negra que no se puede ampliar ni explicar |
| Arduino Uno (ATmega328P) | Similar a la Leonardo | Muy común | Su chip no hace USB: para ser un mando HID hay que cambiar el firmware del conversor USB |
| Raspberry Pi Pico (RP2040) | Más barata que la Leonardo | Más potente | Menos material de clase y librerías de mando menos maduras |

**Decisión:** el encoder comercial es más barato, pero lo que pide el reto (y la rúbrica) es un mando **programable y personalizable**: con el Leonardo el restaurante puede cambiar qué hace cada botón para cada juego desde el puerto serie, sin tocar el código, y el mismo firmware sirve para otra recreativa. La diferencia (unos 35 €) es pequeña frente al presupuesto total.

