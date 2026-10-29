# Tarea 54 · Medir rendimiento y recursos en el equipo real

**Responsable:** Eneko.S · **Fechas:** 03–04/11/2026 · **Depende de:** tareas 17 (rendimiento en VM), 18 (monitorización) y 53 (recreativa instalada en el equipo real)
**Estado:** ⏳ Protocolo y script de resumen preparados el 27/10. Falta medir en el equipo real.

Objetivo: repetir en el equipo físico (1 núcleo, 1 GB) las medidas que las tareas 17 y 18 hicieron en máquina virtual, para responder con datos reales a dos preguntas del enunciado: **¿cuánto rinde MAME con esos recursos?** y **¿mejora con las optimizaciones?** En la VM, el tiempo de arranque «no era concluyente» por el ruido del ordenador anfitrión (tarea 17, sección 5); en el equipo real ese ruido desaparece y además se puede aplicar el gobernador de CPU.

## 1. Herramientas

| Script | Qué mide | Dónde está |
|---|---|---|
| `medir-rendimiento.sh` | Una muestra por arranque: tiempos de arranque, RAM, procesos, servicios, timers, disco y `mame -bench` | [Tarea 17](../17-rendimiento-mame/medir-rendimiento.sh) |
| `optimizar-arcade.sh` | Aplica las 9 optimizaciones | [Tarea 17](../17-rendimiento-mame/optimizar-arcade.sh) |
| `monitor-recreativa.sh` | CPU, memoria, carga, temperatura y consumo de MAME **mientras se juega**, cada 5 s | [`scripts/arcade/`](../../../scripts/arcade/monitor-recreativa.sh) |
| `resumen-monitorizacion.sh` | Resume los CSV de la monitorización (una fila por prueba) | [`scripts/arcade/`](../../../scripts/arcade/resumen-monitorizacion.sh) |
| [`resumir-rendimiento.sh`](resumir-rendimiento.sh) | **Nuevo.** Media ± desviación por etiqueta del CSV de `medir-rendimiento.sh`, en tabla Markdown | Esta carpeta |

`resumir-rendimiento.sh` se ha comprobado con los datos de la VM (`../17-rendimiento-mame/evidencias/rendimiento.csv`): da exactamente la tabla publicada en la tarea 17 (por ejemplo, arranque total 10,71 ± 1,26 s antes y 8,85 ± 2,35 s después; Robby Roto 963 ± 214 % y 1224 ± 11 %).

Todo se copia a la recreativa con el USB 2 de la tarea 53. Las medidas se lanzan desde la consola: `Ctrl+Alt+F2` y entrar como `tecnico`; `Ctrl+Alt+F1` vuelve a MAME.

```bash
sudo mount /dev/sdb1 /mnt
sudo mkdir -p /opt/medidas && sudo cp /mnt/*.sh /opt/medidas/ && sudo chmod +x /opt/medidas/*.sh
cd /opt/medidas
```

## 2. Condiciones

Para que antes y después se puedan comparar, todo igual salvo la optimización:

- El mismo equipo, con la misma limitación de recursos (si se usó `maxcpus=1 mem=1024M`, tarea 53, sección 3).
- Sin el cable de red ni la Wi-Fi durante las medidas, o siempre conectada: lo mismo en las dos fases. Apuntar cuál.
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
| 8 | Sacar los datos | `sudo cp /root/rendimiento.csv ~/monitor/*.csv ~/salida-optimizar.log /mnt/ && sudo umount /mnt` | 1 min |

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
| Equipo | |
| CPU y núcleos usados | |
| RAM disponible para el sistema | |
| Kernel y MAME | |
| Red durante las medidas | |

### 4.2 Arranque, recursos y velocidad (`medir-rendimiento.sh`, 3 + 3 muestras)

*(Pegar aquí la tabla de `resumir-rendimiento.sh`.)*

### 4.3 Durante la partida (`monitor-recreativa.sh`)

*(Pegar aquí la tabla de `resumen-monitorizacion.sh`: reposo, antes y después.)*

### 4.4 Comparación con la VM

| Medida | VM 2 núcleos / 1,5 GB (tarea 17), antes → después | VM 1 núcleo / 1 GB, antes (calculado con `resumir-rendimiento.sh` sobre `rendimiento-1gb.csv`) | Equipo real antes | Equipo real después |
|---|---|---|---|---|
| Arranque total | 10,71 s → 8,85 s | 5,86 ± 0,30 s | | |
| MAME abierto a los | 11,89 s → 10,12 s | 7,13 ± 0,33 s | | |
| RAM usada con MAME | 425 → 424 MB | 400 ± 6 MB | | |
| Robby Roto (`-bench`) | 963 % → 1224 % | 685 ± 11 % | | |

## 5. Cómo leer los resultados

- **Velocidad de MAME (`-bench`):** 100 % es la velocidad de la máquina original. Por debajo de 100 % el juego va lento; por encima, sobra potencia.
- **Desviación típica:** si la diferencia entre antes y después es menor que la desviación, el cambio **no es concluyente** (igual que en la tarea 17).
- **Durante la partida:** CPU cerca del 100 % sostenido, carga por encima de 1, memoria disponible por debajo de unos 100 MB o swap en uso son señales de que el equipo va al límite (tarea 18, sección 6; umbrales orientativos).
- **Temperatura:** en el equipo real sí hay sensores (en la VM la columna salía vacía). Si se acerca a 80-90 °C, revisar la ventilación de la recreativa.

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
| `partida.jpg` | Foto de la partida en el equipo real |

## 8. Pendiente

- [ ] Tarea 53 hecha (recreativa instalada en el equipo real).
- [ ] Pasos 1 a 8 del protocolo.
- [ ] Rellenar las secciones 4 y 6 y guardar las evidencias.
