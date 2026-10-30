# Tarea 17 · Pruebas de rendimiento de MAME antes y después

**Responsable:** Iker · **Fecha de ejecución:** 22/10/2026 · **Depende de:** tarea 16
**Estado:** ✅ Hecha (29/10: alcance ajustado): método, scripts (`medir-rendimiento.sh`, `optimizar-arcade.sh`), las 9 optimizaciones y la medida de antes y después en una VM de 2 núcleos y 1,5 GB. **La medida en 1 núcleo y 1 GB, la que pide el enunciado, está hecha en la [tarea 54](../54-medidas-equipo-real/DOCUMENTACION.md)** (29/10, `Recreativa-53`): MAME va de sobra y la optimización baja timers y disco sin cambiar la velocidad

> ⚠️ **Las cifras de esta página no son las del equipo del cliente; las de 1 núcleo y 1 GB salen en la [tarea 54](../54-medidas-equipo-real/DOCUMENTACION.md).** Estas medidas se hicieron en una VM con **2 núcleos y 1,5 GB**, pero el enunciado dice que la recreativa
> tiene **1 núcleo y 1 GB**. Ya hay una VM con esas especificaciones (`Recreativa-1GB`) con 3 medidas de "antes"
> ([`evidencias/rendimiento-1gb.csv`](evidencias/rendimiento-1gb.csv)); faltan las de "después". Además, el equipo decidió probar
> **Batocera**: su VM (`Batocera`, 1 núcleo, 1 GB) arranca, pero sus medidas están sin hacer. Ver [`../16-batocera/NOTAS.md`](../16-batocera/NOTAS.md).
>
> **Mientras no se repitan, esta tarea no demuestra nada sobre el equipo del cliente.** El enunciado dice «un procesador de un núcleo y 1 GB de RAM» y «dejando constancia de las pruebas de rendimiento»: con 2 núcleos, MAME tiene un núcleo para él y el sistema otro, y con 1,5 GB no hay presión de memoria. Las tablas de abajo se sustituyen por las de `Recreativa-1GB` cuando estén.
>
> Además, `-bench` emula **sin pantalla y sin límite de velocidad**: no es lo mismo que jugar. Falta medir **jugando** (FPS, CPU y RAM durante una partida) con `monitor-recreativa.sh` de la [tarea 18](../18-monitorizacion-recreativa.md).

## 1. Resumen

| | Antes | Después | Cambio |
|---|---|---|---|
| Tareas programadas (timers) | 8 | **3** | **−62 %** |
| Servicios en marcha | 10 | **9** | −10 % |
| Disco usado | 2296 MB | **2019 MB** | **−12 %** (−277 MB) |
| Velocidad de MAME, Gridlee | 1720 % ± 90 | 1825 % ± 44 | +6 % |
| Velocidad de MAME, Robby Roto | 963 % ± 214 | 1224 % ± 11 | +27 %, mucho más estable |
| Arranque total | 10,7 s ± 1,3 | 8,9 s ± 2,4 | no concluyente (ver §5) |
| RAM usada con MAME abierto | 425 MB | 424 MB | sin cambio |

**Conclusión:** la optimización **quita el trabajo en segundo plano** (actualizaciones automáticas, índices, comprobaciones de disco),
que es lo que podría dar tirones en mitad de una partida, y **libera 277 MB de disco**. MAME rinde igual o algo mejor y,
sobre todo, de forma **más estable**. El tiempo de arranque no se puede comparar bien en la máquina virtual por el ruido del ordenador anfitrión.

## 2. Método
- **Misma máquina, mismas condiciones:** VM `Recreativa` (2 CPU y 1,5 GB de RAM; Debian 13.7, MAME 0.276), con la configuración de la tarea 16.
- **3 muestras antes y 3 después**, cada una tras un **reinicio completo**. Se da la media ± la desviación típica.
- En cada arranque, [`medir-rendimiento.sh`](medir-rendimiento.sh) espera a que MAME esté abierto, deja 20 s para que el sistema se asiente y mide:

| Medida | Cómo se obtiene |
|---|---|
| Arranque (kernel / espacio de usuario / total) | `systemd-analyze` |
| Segundo en que se abre MAME | Hora de inicio del proceso `mame` (`/proc/<pid>/stat`) |
| RAM usada / RAM de MAME | `free -m` / RSS de `mame` |
| Procesos, servicios y timers | `ps -e`, `systemctl list-units`, `systemctl list-timers` |
| Disco usado | `df -m /` |
| Velocidad de MAME | `mame -bench 30 <juego>`: emula 30 s sin limitar la velocidad. 100 % = velocidad de la máquina original |

Datos brutos: [`evidencias/rendimiento.csv`](evidencias/rendimiento.csv).

## 3. Estado inicial (antes)
De [`evidencias/antes-sistema.txt`](evidencias/antes-sistema.txt):
- **8 timers** activos: `apt-daily`, `apt-daily-upgrade`, `man-db`, `e2scrub_all`, `dpkg-db-backup`, `logrotate`, `fstrim` y `systemd-tmpfiles-clean`.
- Servicios: `cron`, `dbus`, `getty@tty1`, `ssh`, `journald`, `logind`, `timesyncd` y `udevd`, más las sesiones de usuario.
- Sin `cpufreq` (es una máquina virtual) y con dos kernels instalados (6.12.107 y 6.12.113).
- `systemd-analyze blame`: no hay ningún servicio lento; el más lento tarda 0,58 s (el disco).

## 4. Optimizaciones aplicadas
Script reproducible: [`optimizar-arcade.sh`](optimizar-arcade.sh). Log: [`evidencias/salida-optimizar-arcade.log`](evidencias/salida-optimizar-arcade.log).

| # | Cambio | Por qué |
|---|---|---|
| 1 | Mover `apt-daily` y `apt-daily-upgrade` a las 04:30 y 05:00, con `unattended-upgrades` | Descargan e instalan actualizaciones en segundo plano: CPU, disco y red. A esa hora el local está cerrado y no hay partidas. **Corrección del 24/10/2026:** la primera versión los desactivaba, y la recreativa (que está en la Wi-Fi de clientes) se quedaba sin actualizaciones de seguridad; eso va contra la seguridad por defecto. Las medidas de esta página se tomaron con la primera versión: con la nueva quedan 2 timers más (5 en vez de 3), que no se ejecutan durante el horario del local. |
| 2 | Desactivar `man-db.timer` | Regenera el índice de las páginas de manual, que en una recreativa no se usan. |
| 3 | Desactivar `e2scrub_all` y `e2scrub_reap` | Solo sirven con LVM, y aquí no hay LVM. |
| 4 | Desactivar `dpkg-db-backup.timer` | Copia diaria de la base de datos de paquetes, que no cambia en una máquina dedicada. |
| 5 | Desactivar `cron` | No tiene tareas propias: las diarias ya las llevan los timers de systemd. |
| 6 | `vm.swappiness = 10` | Que MAME no acabe en swap mientras quede RAM libre. |
| 7 | Logs limitados a 50 MB | Evita que el disco se llene con el tiempo. |
| 8 | Gobernador de CPU en `performance` | Solo en máquinas físicas: la CPU no baja de frecuencia en plena partida. En la VM se omite. |
| 9 | `apt autoremove --purge` y `apt clean` | Quita el kernel antiguo y la caché de paquetes: −277 MB. |

**Lo que NO se ha tocado, a propósito:**
- **AppArmor** sigue activo, porque es seguridad.
- **SSH** sigue activo, porque sirve para administrar.
- **`logrotate`**, **`fstrim`** y **`tmpfiles-clean`** se mantienen: son necesarios y casi no consumen.
- **`mitigations=off`** se descartó: daría algo de rendimiento a cambio de desactivar protecciones del procesador.

## 5. Resultados

| Medida | Antes (media ± desv.) | Después (media ± desv.) | Cambio |
|---|---|---|---|
| Kernel | 7,95 s ± 1,64 | 5,71 s ± 2,17 | −28 % * |
| Espacio de usuario | 2,76 s ± 0,38 | 3,14 s ± 0,41 | +13 % * |
| Arranque total | 10,71 s ± 1,26 | 8,85 s ± 2,35 | −17 % * |
| MAME abierto a los | 11,89 s ± 1,28 | 10,12 s ± 2,43 | −15 % * |
| RAM usada | 425 MB | 424 MB | 0 % |
| RAM de MAME | 325 MB | 328 MB | +1 % |
| Procesos | 120 | 119 | −1 % |
| Servicios en marcha | 10 | 9 | −10 % |
| Timers | 8 | 3 | −62 % |
| Disco | 2296 MB | 2019 MB | −12 % |
| Gridlee (`-bench`) | 1720 % ± 90 | 1825 % ± 44 | +6 % |
| Robby Roto (`-bench`) | 963 % ± 214 | 1224 % ± 11 | +27 % |

\* **No concluyente.** Las diferencias son menores que la variación entre muestras. El tiempo del kernel no depende de nada de lo que se ha cambiado,
y aun así varía entre 2,9 s y 9,2 s. Esa variación viene del ordenador anfitrión, que tenía otra máquina virtual encendida con 6 GB de RAM.

**Interpretación:**
- Los cambios **seguros**, que no dependen del ruido, son: timers 8 → 3, servicios 10 → 9 y disco −277 MB.
- La RAM no cambia porque los timers no ocupan memoria mientras esperan. Su efecto está en **cuándo** se ejecutan: en mitad de una partida.
- MAME va de sobra en los dos casos: entre 10 y 18 veces la velocidad real. En Robby Roto la desviación pasa de ±214 a ±11:
  el rendimiento es mucho **más estable**, que es lo que importa para que el juego no dé tirones.

## 6. Cómo repetirlo en la máquina física
```bash
# 3 veces: reiniciar, y al arrancar (Ctrl+Alt+F2 → tecnico):
sudo ./medir-rendimiento.sh antes --bench
# Optimizar:
sudo ./optimizar-arcade.sh
# 3 veces: reiniciar, y al arrancar:
sudo ./medir-rendimiento.sh despues --bench
# Resultados:
sudo cat /root/rendimiento.csv
```
En la máquina física los tiempos de arranque serán mucho más estables, y además se aplica el gobernador de CPU (#8).

## 7. Incidencias

| # | Incidencia | Solución |
|---|---|---|
| 1 | Una sola medida de arranque no era fiable: 4,7 s en un arranque y 12,1 s en otro | Se toman 3 muestras con reinicio y se da la media ± la desviación |
| 2 | En el CSV, el tiempo de MAME salía como `10,08` y la coma del idioma español rompía las columnas | `export LC_ALL=C` en `medir-rendimiento.sh`. Las 3 filas del "antes" se corrigieron a mano. |

## 8. Pendiente
- [x] Antes y después en 1 núcleo y 1 GB, y medir jugando con `monitor-recreativa.sh`: pasan a la [tarea 54](../54-medidas-equipo-real/DOCUMENTACION.md) (29/10), con estos mismos scripts.
- [ ] Pasar a Adrian (tarea 18, monitorización) la lista de timers y servicios que quedan activos.
