# Mando arcade (firmware HID)

Firmware del arcade stick de la recreativa para **Arduino Leonardo** (ATmega32U4). El mando se conecta por USB como un joystick HID estándar, sin drivers. El mapeo de botones se puede cambiar por el puerto serie y se guarda en la EEPROM.

Tareas relacionadas en el [backlog](../../docs/gestion/backlog-kanban.csv): #19 (montaje), #20 (firmware), #50 (prueba en físico) y #21 (pruebas con emuladores).

## Estado

| Parte | Estado |
|---|---|
| Firmware HID (2 ejes, 8 botones) | Hecho, compila |
| Mapeo configurable guardado en EEPROM | Hecho, compila |
| Comandos por puerto serie | Hecho, compila |
| **Prueba en la placa real** | **Pendiente (tarea #50, Adrian)** |
| Pruebas con MAME y otro emulador | Pendiente (tarea #21) |

Hasta ahora solo se ha comprobado que compila (`pio run`: Flash 38 %, RAM 17 %). No se ha ejecutado en ninguna placa.

## Conexiones

| Elemento | Pin del Leonardo |
|---|---|
| Eje X del stick | A0 |
| Eje Y del stick | A1 |
| Botón físico 1 | 2 → GND |
| Botón físico 2 | 3 → GND |

Los botones van entre el pin y GND, sin resistencia, porque se usa la resistencia interna (`INPUT_PULLUP`). El stick analógico se alimenta a 5 V. Para añadir botones, se meten sus pines en `PINES_BOTON` dentro de [src/main.cpp](src/main.cpp).

## Compilar y subir

Con PlatformIO (extensión de VS Code o CLI), desde esta carpeta:

```bash
pio run -t upload
```

La librería `mheironimus/Joystick` se descarga sola (está en [platformio.ini](platformio.ini)).

## Configuración por puerto serie

Abre el monitor serie a 9600 baudios:

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

**Valores por defecto:** botón físico 1 → HID 1, botón físico 2 → HID 2, ejes sin invertir, zona muerta 20.

Al arrancar se lee la EEPROM. Si está vacía o los datos no son válidos (no coincide el número de control, la versión o el checksum), se usan los valores por defecto.

## Pendiente: prueba en físico (tarea #50)

Responsable: **Adrian**. Revisa: Eneko.P. Necesita el stick montado (#19).

Para cada punto, guardar captura o foto como evidencia.

- [ ] Subir el firmware a la placa sin errores.
- [ ] El PC lo reconoce como mando: `jstest /dev/input/js0` en Linux o `joy.cpl` en Windows.
- [ ] Los ejes van de 0 a 1023 y se quedan quietos en el centro con la zona muerta.
- [ ] Cada botón físico se marca al pulsarlo y se suelta al soltarlo.
- [ ] El monitor serie responde a `VER`.
- [ ] `MAP 1 3`: el botón físico 1 pasa a salir como botón 3 y el 1 deja de marcarse.
- [ ] `INV X` invierte el eje X.
- [ ] `GUARDAR`, desenchufar, volver a enchufar y `VER`: el cambio se mantiene.
- [ ] `RESET` + `GUARDAR` deja los valores por defecto.

Si todo pasa, la tarea #20 se marca como *Hecho* y se pasa a las pruebas con MAME y otro emulador (#21).
