# Tarea 18: Monitorización de recursos de la recreativa

- **Bloque:** 3 Arcade
- **Depende de:** tarea 16 (recreativa Debian + MAME, Iker); Batocera es la alternativa de la tarea 51
- **Responsable:** Adrian
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** scripts listos y probados en Linux; **no se han ejecutado nunca en la recreativa**: pendiente en la VM de 1 núcleo y 1 GB
- **Fecha:** 23/10/2026

## 1. Objetivo

La recreativa tiene recursos muy justos (1 núcleo y 1 GB de RAM). Con Debian y MAME, el sistema usa unos 425 MB con MAME abierto (tarea 17). La alternativa, Batocera, arranca con 1 GB pero su propia guía pide **2 GB** ([notas de la tarea 51](16-batocera/NOTAS.md)). Hay que medir cuánto consume MAME para saber si va sobrado o al límite, y comprobar con datos si las optimizaciones de la tarea 17 mejoran algo.

## 2. Archivos

| Archivo | Qué hace |
|---|---|
| `scripts/arcade/monitor-recreativa.sh` | Toma una muestra cada pocos segundos y la guarda en un CSV |
| `scripts/arcade/resumen-monitorizacion.sh` | Resume uno o varios CSV en una tabla (por ejemplo, antes y después) |

Solo leen `/proc` y `/sys`, así que funcionan en Debian y en Batocera sin instalar nada. Están escritos en `sh` estándar, compatible con BusyBox.

## 3. Qué se mide

| Columna | Significado |
|---|---|
| `fecha_hora`, `segundos` | Momento de la muestra y segundos desde el inicio |
| `cpu_pct` | Uso de CPU de todo el sistema (%) |
| `carga_1min` | Carga media del último minuto. Con 1 núcleo, por encima de 1 hay procesos esperando |
| `mem_total_mb`, `mem_usada_mb`, `mem_disponible_mb` | Memoria total, usada y disponible para nuevos programas |
| `swap_usada_mb` | Memoria de intercambio en uso. Si sube, falta RAM |
| `temp_c` | Temperatura más alta de los sensores. Vacía en una máquina virtual |
| `proc_cpu_pct`, `proc_rss_mb` | CPU y memoria del emulador (por defecto, el proceso `mame`) |

## 4. Cómo usarlo en la recreativa (Debian 13 + MAME)

El sistema elegido, de momento, es **Debian 13 con MAME** (tareas 16 y 17); Batocera está en estudio (tarea 51, sección 4.5). La recreativa está en la Wi-Fi de invitados, aislada, así que **no se llega a ella por SSH desde la LAN** ([tarea 23, apartado 5.2](../redes/23-plano-direccionamiento.md#52-decisión-red-plana-con-red-de-invitados-aislada-24102026)): los scripts se ejecutan **en la propia recreativa, desde su consola**.

### 4.1 Copiar los scripts

Con un USB (o con `git clone` del repositorio, si la recreativa tiene salida a internet). En la recreativa, `Ctrl+Alt+F2` y entrar como `tecnico`:

```
sudo mkdir -p /opt/monitor && sudo cp /media/usb/scripts/arcade/*.sh /opt/monitor/
```

En la VM de pruebas, que sí tiene SSH por el reenvío de puertos de VirtualBox (tarea 16):

```
scp -P 2222 scripts/arcade/*.sh tecnico@127.0.0.1:/tmp/
```

### 4.2 Nombre del proceso del emulador

En Debian el proceso se llama `mame`, que es el valor por defecto. Se comprueba con un juego abierto:

```
pgrep -a mame
```

### 4.3 Medir mientras se juega

En tty2, en segundo plano, y volver a tty1 (`Ctrl+Alt+F1`) para jugar con el stick:

```
mkdir -p ~/monitor
nohup sh /opt/monitor/monitor-recreativa.sh -e antes -i 5 -d 600 -o ~/monitor > /dev/null 2>&1 &
```

Esto toma una muestra cada 5 segundos durante 10 minutos. Para pararlo antes: `pkill -f monitor-recreativa`.

Opciones:

| Opción | Por defecto | Para qué |
|---|---|---|
| `-i` | 5 | Segundos entre muestras |
| `-d` | 300 | Duración total; 0 = sin límite |
| `-e` | prueba | Etiqueta del CSV: `reposo`, `antes`, `despues`… |
| `-o` | `/userdata/monitor` si existe (Batocera); si no, `./monitor` | Carpeta de salida |
| `-p` | mame | Proceso del emulador |

### 4.4 Sacar los resultados y resumirlos

Copiar `~/monitor/monitor_*.csv` a un USB (o con `scp -P 2222` desde la VM) y, en el PC:

```
sh scripts/arcade/resumen-monitorizacion.sh docs/evidencias/18-monitorizacion/*.csv
```

El resumen saca una fila por CSV: número de muestras, CPU media y máxima, memoria usada media, memoria disponible mínima, temperatura máxima y CPU media del emulador.

### 4.5 Si se elige Batocera (tarea 51)

Los scripts están en `sh` estándar, compatible con BusyBox, y solo leen `/proc` y `/sys`, así que también funcionan allí. Cambia dónde se copian (`/userdata/monitor`, la partición de datos que se conserva al reiniciar) y el nombre del proceso, que puede ser `retroarch` en vez de `mame` (`-p retroarch`). En Batocera se entra como `root`: antes hay que cambiar su contraseña por defecto (sección 8).

## 5. Protocolo de medida (coordinado con la tarea 17)

Para que antes y después se puedan comparar, las medidas se hacen en la VM **`Recreativa-1GB` (1 núcleo y 1 GB)**, la que pide el enunciado, y siempre igual:

1. **Reposo:** MAME en su menú, sin juego, 5 minutos (`-e reposo -d 300`).
2. **Antes:** el mismo juego, 10 minutos jugando (`-e antes -d 600`).
3. Se aplica `optimizar-arcade.sh` (tarea 17) y se reinicia.
4. **Después:** el mismo juego y la misma duración (`-e despues -d 600`).
5. Se guardan los CSV y la salida del resumen en `docs/evidencias/18-monitorizacion/`.

## 6. Cómo interpretar los datos

| Señal | Lectura |
|---|---|
| `cpu_pct` cerca de 100 % de forma sostenida | La CPU es el cuello de botella: el juego puede ir a tirones |
| `carga_1min` por encima de 1 | Con un solo núcleo, hay procesos esperando turno |
| `mem_disponible_mb` mínima por debajo de unos 100 MB | Memoria al límite |
| `swap_usada_mb` mayor que 0 | El sistema se ha quedado sin RAM y usa disco, que es mucho más lento |
| `proc_cpu_pct` casi igual a `cpu_pct` | Casi toda la CPU la usa el emulador; el sistema está bien optimizado |

Estos umbrales son orientativos, no datos del fabricante.

## 7. Pruebas realizadas

En un Linux normal (no Batocera), con `dash` y `bash`:

| Prueba | Resultado |
|---|---|
| 6 muestras con un proceso falso llamado `mame` que consume CPU | CSV correcto; el uso del proceso coincide con el del sistema |
| Proceso inexistente (`-p noexiste`) | Sigue midiendo; las columnas del proceso quedan a 0 |
| Valores incorrectos (`-i 0`, `-d abc`, `-e "a b"`) | Rechazados con un mensaje, sin crear el CSV |
| Parada con Ctrl+C en una terminal y con `kill` | Para limpiamente y conserva las muestras tomadas |
| Resumen de dos CSV | Una fila por fichero con medias y extremos |

**Falta:** ejecutarlo en la VM `Recreativa-1GB` (1 núcleo, 1 GB) durante una partida, siguiendo el protocolo de la sección 5, y guardar los CSV como evidencia.

## 8. Seguridad

- En Debian los scripts se ejecutan como `tecnico` (no hace falta `root`). SSH solo admite clave (tarea 16).
- Si se elige Batocera: su SSH usa `root` con una contraseña por defecto conocida. Hay que cambiarla antes de conectar la recreativa a la red del local y desactivar el SSH cuando no se use. Se revisará en la tarea 46.
- Los scripts solo leen información del sistema y escriben en su carpeta de salida. No cambian nada.

## 9. Limitaciones

- En una máquina virtual no hay sensores de temperatura: la columna `temp_c` queda vacía.
- `cpu_pct` es el porcentaje del total de núcleos. En la recreativa (1 núcleo) coincide con el uso del único núcleo.
- Si se abren varios procesos con el mismo nombre, se vigila el primero que se encuentra.
- La toma de muestras consume algo de CPU, despreciable con intervalos de 5 segundos o más.
