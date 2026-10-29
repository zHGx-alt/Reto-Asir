# Tarea 54 · Medir rendimiento y recursos en la recreativa de 1 núcleo y 1 GB

**Responsable:** Eneko.S · **Fechas:** 03–04/11/2026 · **Depende de:** tareas 17 (rendimiento en VM), 18 (monitorización) y 53 (recreativa de 1 núcleo y 1 GB con el stick)
**Estado:** ✅ Medido el 29/10/2026 en `Recreativa-53` (1 núcleo y 1 GB): 3 arranques antes y 3 después de optimizar, reposo y 10 min de juego antes y después. Con estas medidas se cierran también las tareas 17 y 18 en 1 GB.

Objetivo: medir en `Recreativa-53`, la VM de **1 núcleo y 1 GB** que pide el enunciado (el equipo decidió el 29/10 entregar la recreativa en VM), lo que las tareas 17 y 18 midieron en una VM de 2 núcleos y 1,5 GB, para responder con datos a dos preguntas del enunciado: **¿cuánto rinde MAME con esos recursos?** y **¿mejora con las optimizaciones?** Desde el 29/10 esta tarea es la única que mide en 1 núcleo y 1 GB: la 17 (método y scripts) y la 18 (scripts de monitorización) quedan cerradas y sus medidas en 1 GB se hacen aquí. En una VM el tiempo de arranque tiene ruido del ordenador anfitrión (tarea 17, sección 5): se cierran los demás programas y se toman 3 muestras de cada fase.

## 1. Herramientas

| Script | Qué mide | Dónde está |
|---|---|---|
| `medir-rendimiento.sh` | Una muestra por arranque: tiempos de arranque, RAM, procesos, servicios, timers, disco y `mame -bench` | [Tarea 17](../17-rendimiento-mame/medir-rendimiento.sh) |
| `optimizar-arcade.sh` | Aplica las 9 optimizaciones | [Tarea 17](../17-rendimiento-mame/optimizar-arcade.sh) |
| `monitor-recreativa.sh` | CPU, memoria, carga, temperatura y consumo de MAME **mientras se juega**, cada 5 s | [`scripts/arcade/`](../../../scripts/arcade/monitor-recreativa.sh) |
| `resumen-monitorizacion.sh` | Resume los CSV de la monitorización (una fila por prueba) | [`scripts/arcade/`](../../../scripts/arcade/resumen-monitorizacion.sh) |
| [`resumir-rendimiento.sh`](resumir-rendimiento.sh) | **Nuevo.** Media ± desviación por etiqueta del CSV de `medir-rendimiento.sh`, en tabla Markdown | Esta carpeta |

`resumir-rendimiento.sh` se ha comprobado con los datos de la VM (`../17-rendimiento-mame/evidencias/rendimiento.csv`): da exactamente la tabla publicada en la tarea 17 (por ejemplo, arranque total 10,71 ± 1,26 s antes y 8,85 ± 2,35 s después; Robby Roto 963 ± 214 % y 1224 ± 11 %).

Los scripts se copian a la VM por SSH (puerto 2223, tarea 53) desde el repositorio:

```bash
scp -P 2223 docs/arcade/17-rendimiento-mame/medir-rendimiento.sh docs/arcade/17-rendimiento-mame/optimizar-arcade.sh scripts/arcade/*.sh tecnico@127.0.0.1:
ssh -t -p 2223 tecnico@127.0.0.1 'sudo mkdir -p /opt/medidas && sudo cp ~/*.sh /opt/medidas/ && sudo chmod +x /opt/medidas/*.sh'
```

Las medidas se lanzan dentro de la VM, en la consola: `Ctrl+Alt+F2` (en VirtualBox, `Ctrl derecho + F2`) y entrar como `tecnico`, en `/opt/medidas`; `Ctrl+Alt+F1` vuelve a MAME. También se pueden lanzar por SSH.

## 2. Condiciones

Para que antes y después se puedan comparar, todo igual salvo la optimización:

- La misma VM (`Recreativa-53`, 1 núcleo y 1 GB) y el mismo anfitrión, con los demás programas y VM cerrados durante las medidas.
- La red NAT conectada en las dos fases.
- El mismo juego para jugar: **Robby Roto** (`robby`), que en la VM fue el más exigente y el más variable.
- Cada muestra de arranque, tras un **reinicio completo** (`sudo reboot`).

## 3. Protocolo

| Paso | Qué | Comando (en `/opt/medidas`) | Tiempo |
|---|---|---|---|
| 1 | Ficha: recursos y versión | `nproc; free -m; uname -r; /usr/games/mame -version` → `00-ficha.txt` | 2 min |
| 2 | **Antes**, 3 arranques | Reiniciar y, al arrancar: `sudo ./medir-rendimiento.sh antes --bench` (3 veces) | 3 × 3 min |
| 3 | **Reposo** | MAME en su menú sin jugar: `sh monitor-recreativa.sh -e reposo -d 300 -o ~/monitor` | 5 min |
| 4 | **Partida antes** | `nohup sh monitor-recreativa.sh -e antes -d 600 -o ~/monitor >/dev/null 2>&1 &`, `Ctrl+Alt+F1` y jugar a Robby Roto 10 min | 10 min |
| 5 | Optimizar | `sudo ./optimizar-arcade.sh 2>&1 \| tee ~/salida-optimizar.log` y reiniciar | 2 min |
| 6 | **Después**, 3 arranques | `sudo ./medir-rendimiento.sh despues --bench` tras cada reinicio (3 veces) | 3 × 3 min |
| 7 | **Partida después** | Igual que el paso 4 con `-e despues` | 10 min |
| 8 | Sacar los datos (desde el anfitrión) | `ssh -p 2223 tecnico@127.0.0.1 'sudo cat /root/rendimiento.csv' > evidencias/rendimiento.csv` y `scp -P 2223 'tecnico@127.0.0.1:monitor/*.csv' tecnico@127.0.0.1:salida-optimizar.log evidencias/` | 1 min |

Total: alrededor de una hora. En el PC, con los ficheros copiados a `evidencias/`:

```bash
sh docs/arcade/54-medidas-equipo-real/resumir-rendimiento.sh docs/arcade/54-medidas-equipo-real/evidencias/rendimiento.csv
sh scripts/arcade/resumen-monitorizacion.sh docs/arcade/54-medidas-equipo-real/evidencias/monitor_*.csv
```

Las dos salidas se pegan en la sección 4.

## 4. Resultados (29/10/2026)

### 4.1 Equipo

| Dato | Valor |
|---|---|
| VM y anfitrión | `Recreativa-53` en VirtualBox, en el PC de Eneko.S (Ubuntu, perfil de energía *balanced*) |
| CPU y núcleos usados | 1 |
| RAM disponible para el sistema | 967 MB (tarea 53, P3) |
| Kernel y MAME | 6.12.113+deb13-amd64 · MAME 0.276 |
| Red durante las medidas | NAT conectada en las dos fases |
| Juego en las medidas durante la partida | *The Adventures of Robby Roto!* |

### 4.2 Arranque, recursos y velocidad (`medir-rendimiento.sh`, 3 + 3 muestras)

Salida de `resumir-rendimiento.sh` sobre [`rendimiento-comparado.csv`](evidencias/rendimiento-comparado.csv) (media ± desviación):

| Medida | antes (n=3) | despues (n=3) | Cambio |
|---|---|---|---|
| kernel_s | 11.45 ± 0.01 | 11.46 ± 0.01 | +0 % |
| userspace_s | 3.06 ± 0.02 | 2.95 ± 0.07 | -4 % |
| total_s | 14.51 ± 0.00 | 14.40 ± 0.07 | -1 % |
| mame_abierto_s | 15.75 ± 0.04 | 15.70 ± 0.08 | -0 % |
| ram_usada_mb | 474.33 ± 8.99 | 485.00 ± 15.12 | +2 % |
| rss_mame_mb | 338.00 ± 0.82 | 339.33 ± 1.25 | +0 % |
| procesos | 187.33 ± 0.47 | 187.67 ± 1.25 | +0 % |
| servicios | 10.00 ± 0.00 | 10.00 ± 0.00 | +0 % |
| timers | 8.00 ± 0.00 | 5.00 ± 0.00 | -38 % |
| disco_mb | 2304.00 ± 0.00 | 2029.33 ± 0.47 | -12 % |
| bench_gridlee_pct | 1012.44 ± 22.36 | 1020.66 ± 7.45 | +1 % |
| bench_robby_pct | 773.20 ± 16.34 | 776.89 ± 3.85 | +0 % |

Las medidas de «después» de esta tabla son las repetidas a las 13:47-13:50 con el anfitrión libre. Las primeras (13:20-13:25) se descartaron por la incidencia 1 de la sección 7.

### 4.3 Durante la partida (`monitor-recreativa.sh`, una muestra cada 5 s)

| Prueba | Muestras | CPU media | CPU máxima | Memoria usada media | Memoria disponible mínima | Temperatura | CPU de MAME |
|---|---|---|---|---|---|---|---|
| Reposo (menú de MAME, 5 min) | 60 | 31,5 % | 35,0 % | 482 MB | 484 MB | n/d (VM) | 32,0 % |
| Antes, *Robby Roto* 10 min | 120 | 52,3 % | 65,0 % | 454 MB | 510 MB | n/d | 51,1 % |
| Después, *Robby Roto* 10 min | 120 | 58,4 % | 62,0 % | 496 MB | 466 MB | n/d | 56,9 % |

Swap usada: 0 en todas. La medida «después» jugando se hizo con el anfitrión ocupado (incidencia 1), así que su CPU, algo más alta, no se compara con la de «antes»: lo que importa es que en ningún caso la recreativa se acerca al límite.

### 4.4 Comparación con las otras VM

| Medida | VM 2 núcleos / 1,5 GB (tarea 17), antes → después | `Recreativa-1GB` (tareas 17 y 51), antes | `Recreativa-53` antes | `Recreativa-53` después |
|---|---|---|---|---|
| Arranque total | 10,71 s → 8,85 s | 5,86 ± 0,30 s | 14,51 ± 0,00 s | 14,40 ± 0,07 s |
| MAME abierto a los | 11,89 s → 10,12 s | 7,13 ± 0,33 s | 15,75 ± 0,04 s | 15,70 ± 0,08 s |
| RAM usada con MAME | 425 → 424 MB | 400 ± 6 MB | 474 ± 9 MB | 485 ± 15 MB |
| Robby Roto (`-bench`) | 963 % → 1224 % | 685 ± 11 % | 773 ± 16 % | 777 ± 4 % |

Las VM no son comparables entre sí en tiempos absolutos: cada una se midió en un anfitrión distinto. Sí lo son el antes y el después de una misma VM.

## 5. Cómo leer los resultados

- **Velocidad de MAME (`-bench`):** 100 % es la velocidad de la máquina original. Por debajo de 100 % el juego va lento; por encima, sobra potencia.
- **Desviación típica:** si la diferencia entre antes y después es menor que la desviación, el cambio **no es concluyente** (igual que en la tarea 17).
- **Durante la partida:** CPU cerca del 100 % sostenido, carga por encima de 1, memoria disponible por debajo de unos 100 MB o swap en uso son señales de que el equipo va al límite (tarea 18, sección 6; umbrales orientativos).
- **Temperatura:** en una VM no hay sensores y la columna sale vacía; no se puede medir.

## 6. Conclusión

1. **MAME rinde de sobra con 1 núcleo y 1 GB.** *Robby Roto* emula a 7,8 veces la velocidad real y *Gridlee* a 10 veces. Jugando, la CPU media está en el 52-58 % (máximo 65 %), quedan siempre más de 460 MB libres y no se usa swap.
2. **La optimización quita trabajo en segundo plano y disco, sin coste.** Tareas programadas de 8 a 5 (−38 %; las actualizaciones de seguridad se mantienen, a las 4:30 y 5:00) y disco de 2304 a 2029 MB (−12 %). Es el mismo resultado que en la tarea 17.
3. **No cambia la velocidad, ni el arranque, ni la memoria.** Las diferencias (−1 % de arranque, +2 % de RAM, +0-1 % de velocidad) son menores que la desviación entre muestras: no son concluyentes. Tiene sentido: los timers no ocupan memoria mientras esperan, y su efecto es evitar que se ejecuten en mitad de una partida.
4. **En una VM, el anfitrión manda.** Con el PC ocupado, la misma VM medía un 45 % menos de velocidad (incidencia 1). Las medidas válidas son las tomadas con el anfitrión libre.

## 7. Incidencias

| # | Incidencia | Causa | Solución |
|---|---|---|---|
| 1 | Las 3 primeras medidas de «después» (13:20-13:25) daban un 45 % menos de velocidad en `-bench` (*Robby Roto* 429 ± 7 % frente a 773 % antes), con muy poca variación | El PC anfitrión estaba ocupado mientras tanto. `optimizar-arcade.sh` no toca nada que afecte a la emulación, y `-bench` usa solo CPU (sin imagen ni sonido) | Medida de control ya optimizada, con el anfitrión libre: 777,5 % ([`control.csv`](evidencias/control.csv)). Se repitieron las 3 medidas de «después» ([`despues2.csv`](evidencias/despues2.csv)): 777 ± 4 %. Las descartadas quedan en [`rendimiento.csv`](evidencias/rendimiento.csv) |
| 2 | El primer intento del reposo fallaba: `cannot open /opt/medidas/monitor-recreativa.sh` | No se habían copiado los scripts a la VM (paso de la sección 1) | Copiarlos y repetir desde los 3 arranques de «antes» |
| 3 | `pgrep -f monitor-recreativa` devolvía un PID aunque el monitor ya había terminado | `pgrep -f` se encuentra a sí mismo: la orden lanzada por SSH contiene el texto buscado | Comprobar la hora del CSV (deja de crecer a los 600 s) |

## 8. Evidencias (en `evidencias/`)

| Fichero | Qué |
|---|---|
| [`rendimiento-comparado.csv`](evidencias/rendimiento-comparado.csv) | Las 6 muestras válidas: 3 antes y 3 después (tabla 4.2) |
| [`rendimiento.csv`](evidencias/rendimiento.csv) | CSV original de la VM: las 3 de antes y las 3 de después descartadas (incidencia 1) |
| [`despues2.csv`](evidencias/despues2.csv) | Las 3 de después repetidas con el anfitrión libre |
| [`control.csv`](evidencias/control.csv) | Medida de control que aclaró la incidencia 1 |
| [`salida-optimizar.log`](evidencias/salida-optimizar.log) | Salida de `optimizar-arcade.sh` |
| [`monitor_reposo_20261029-125632.csv`](evidencias/monitor_reposo_20261029-125632.csv), [`monitor_antes_20261029-130134.csv`](evidencias/monitor_antes_20261029-130134.csv) y [`monitor_despues_20261029-132504.csv`](evidencias/monitor_despues_20261029-132504.csv) | Monitorización en reposo y jugando (tabla 4.3) |

## 9. Pendiente

- [x] Tarea 53 hecha (`Recreativa-53`, 29/10).
- [x] Protocolo de medidas y resultados.
- [ ] Opcional: repetir los 10 min de juego «después» con el anfitrión libre, para comparar también la CPU jugando.
