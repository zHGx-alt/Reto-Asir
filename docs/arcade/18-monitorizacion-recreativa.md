# Tarea 18: Monitorización de recursos de la recreativa

- **Bloque:** 3 Arcade
- **Depende de:** tarea 16 (Batocera y MAME, Iker)
- **Revisa:** Markel
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** scripts listos y probados en Linux; pendiente de ejecutarlos en la VM de Batocera
- **Fecha:** 23/10/2026

## 1. Objetivo

La recreativa tiene recursos muy justos (1 núcleo y 1 GB de RAM), y Batocera pide 1 GB como mínimo. Hay que medir cuánto consume MAME para saber si va sobrado o al límite, y comprobar con datos si las optimizaciones de la tarea 17 mejoran algo.

## 2. Archivos

| Archivo | Qué hace |
|---|---|
| `scripts/arcade/monitor-recreativa.sh` | Toma una muestra cada pocos segundos y la guarda en un CSV |
| `scripts/arcade/resumen-monitorizacion.sh` | Resume uno o varios CSV en una tabla (por ejemplo, antes y después) |

Solo leen `/proc` y `/sys`, así que funcionan en Batocera sin instalar nada. Están escritos en `sh` estándar, compatible con BusyBox.

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

## 4. Cómo usarlo en Batocera

### 4.1 Copiar los scripts

Desde el PC, con el acceso SSH de Batocera activado y su IP (se ve en el menú de Batocera, en la información de red):

```
ssh root@IP_BATOCERA "mkdir -p /userdata/monitor"
scp scripts/arcade/*.sh root@IP_BATOCERA:/userdata/monitor/
```

`/userdata` es la partición de datos: lo que se guarda ahí no se pierde al reiniciar.

### 4.2 Saber cómo se llama el proceso del emulador

Con un juego abierto, desde SSH:

```
cat /proc/[0-9]*/comm | sort -u
```

Si aparece `mame`, no hay que cambiar nada. Si el juego se ejecuta con el núcleo de RetroArch, aparecerá `retroarch` y hay que añadir `-p retroarch`.

### 4.3 Medir

Para medir mientras se juega, hay que lanzarlo en segundo plano y dejarlo correr:

```
cd /userdata/monitor
nohup sh monitor-recreativa.sh -e antes -i 5 -d 600 > /dev/null 2>&1 &
```

Esto toma una muestra cada 5 segundos durante 10 minutos. Mientras tanto, se juega con el stick. Para pararlo antes de tiempo: `kill <PID>` (el PID lo da `pgrep -f monitor-recreativa`). Si se ejecuta en primer plano, se para con Ctrl+C.

Opciones:

| Opción | Por defecto | Para qué |
|---|---|---|
| `-i` | 5 | Segundos entre muestras |
| `-d` | 300 | Duración total; 0 = sin límite |
| `-e` | prueba | Etiqueta del CSV: `reposo`, `antes`, `despues`… |
| `-o` | `/userdata/monitor` | Carpeta de salida |
| `-p` | mame | Proceso del emulador |

### 4.4 Sacar los resultados y resumirlos

```
scp root@IP_BATOCERA:/userdata/monitor/monitor_*.csv docs/evidencias/18-monitorizacion/
sh scripts/arcade/resumen-monitorizacion.sh docs/evidencias/18-monitorizacion/*.csv
```

El resumen saca una fila por CSV: número de muestras, CPU media y máxima, memoria usada media, memoria disponible mínima, temperatura máxima y CPU media del emulador.

## 5. Protocolo de medida (coordinado con la tarea 17)

Para que antes y después se puedan comparar, las dos medidas se hacen igual:

1. **Reposo:** Batocera en su menú, sin juego, 5 minutos (`-e reposo -d 300`).
2. **Antes:** el mismo juego, 10 minutos jugando (`-e antes -d 600`).
3. Iker aplica las optimizaciones de la tarea 17.
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

**Falta:** ejecutarlo en la VM de Batocera de Iker (1 núcleo, 1 GB) y guardar las evidencias.

## 8. Seguridad

- El acceso SSH de Batocera usa el usuario `root` con una contraseña por defecto conocida. Hay que cambiarla antes de conectar la recreativa a la red del local y desactivar el SSH cuando no se use. Se revisará en la tarea 46.
- Los scripts solo leen información del sistema y escriben en su carpeta de salida. No cambian nada.

## 9. Limitaciones

- En una máquina virtual no hay sensores de temperatura: la columna `temp_c` queda vacía.
- `cpu_pct` es el porcentaje del total de núcleos. En la recreativa (1 núcleo) coincide con el uso del único núcleo.
- Si se abren varios procesos con el mismo nombre, se vigila el primero que se encuentra.
- La toma de muestras consume algo de CPU, despreciable con intervalos de 5 segundos o más.
