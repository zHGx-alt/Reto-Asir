# Tarea 54 · Medir rendimiento y recursos en la recreativa de 1 núcleo y 1 GB

**Responsable:** Eneko.S · **Fechas:** 03–04/11/2026 · **Depende de:** tareas 17 (rendimiento en VM), 18 (monitorización) y 53 (recreativa de 1 núcleo y 1 GB con el stick)
**Estado:** ⏳ Protocolo y script de resumen preparados el 27/10. La recreativa en la que se mide ya existe: `Recreativa-53` (tarea 53, 29/10). Falta medir.

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

## 4. Resultados (rellenar)

### 4.1 Equipo

| Dato | Valor |
|---|---|
| VM y anfitrión | `Recreativa-53` en |
| CPU y núcleos usados | 1 |
| RAM disponible para el sistema | 967 MB (tarea 53, P3) |
| Kernel y MAME | |
| Red durante las medidas | |

### 4.2 Arranque, recursos y velocidad (`medir-rendimiento.sh`, 3 + 3 muestras)

*(Pegar aquí la tabla de `resumir-rendimiento.sh`.)*

### 4.3 Durante la partida (`monitor-recreativa.sh`)

*(Pegar aquí la tabla de `resumen-monitorizacion.sh`: reposo, antes y después.)*

### 4.4 Comparación con las otras VM

| Medida | VM 2 núcleos / 1,5 GB (tarea 17), antes → después | `Recreativa-1GB` (tareas 17 y 51), antes (calculado con `resumir-rendimiento.sh` sobre `rendimiento-1gb.csv`) | `Recreativa-53` antes | `Recreativa-53` después |
|---|---|---|---|---|
| Arranque total | 10,71 s → 8,85 s | 5,86 ± 0,30 s | | |
| MAME abierto a los | 11,89 s → 10,12 s | 7,13 ± 0,33 s | | |
| RAM usada con MAME | 425 → 424 MB | 400 ± 6 MB | | |
| Robby Roto (`-bench`) | 963 % → 1224 % | 685 ± 11 % | | |

## 5. Cómo leer los resultados

- **Velocidad de MAME (`-bench`):** 100 % es la velocidad de la máquina original. Por debajo de 100 % el juego va lento; por encima, sobra potencia.
- **Desviación típica:** si la diferencia entre antes y después es menor que la desviación, el cambio **no es concluyente** (igual que en la tarea 17).
- **Durante la partida:** CPU cerca del 100 % sostenido, carga por encima de 1, memoria disponible por debajo de unos 100 MB o swap en uso son señales de que el equipo va al límite (tarea 18, sección 6; umbrales orientativos).
- **Temperatura:** en una VM no hay sensores y la columna sale vacía; no se puede medir.

## 6. Conclusión (rellenar)

*(¿Rinde MAME con 1 núcleo y 1 GB? ¿Qué mejoró con la optimización y qué no fue concluyente? ¿Hay margen o va al límite?)*

## 7. Evidencias (en `evidencias/`)

| Fichero | Qué |
|---|---|
| `00-ficha.txt` | Paso 1 |
| `rendimiento.csv` | Las 6 muestras de `medir-rendimiento.sh` |
| `salida-optimizar.log` | Paso 5 |
| `monitor_reposo_*.csv`, `monitor_antes_*.csv`, `monitor_despues_*.csv` | Pasos 3, 4 y 7 |
| `resumen.txt` | Salida de los dos scripts de resumen |
| `partida.png` | Captura de la partida durante la medida |

## 8. Pendiente

- [x] Tarea 53 hecha (`Recreativa-53`, 29/10).
- [ ] Pasos 1 a 8 del protocolo.
- [ ] Rellenar las secciones 4 y 6 y guardar las evidencias.
