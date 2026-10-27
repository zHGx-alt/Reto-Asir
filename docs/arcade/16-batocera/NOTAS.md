# Tarea 51 · Batocera frente a Debian en la recreativa (1 núcleo, 1 GB)

**Responsable:** Iker · **Fechas:** 23/10/2026 (instalación) y 26/10/2026 (medidas y decisión) · **Estado:** ✅ Decidido: **Debian 13 mínimo + MAME**

El equipo decidió probar **Batocera** como sistema de la recreativa. El enunciado y el plan solo piden MAME en un equipo de
**1 núcleo y 1 GB**; el plan propone "Debian mínimo / Alpine / Lakka". Esta tarea compara las dos opciones con datos,
en VM con las especificaciones del enunciado, y decide.

## 1. Decisión

**Se queda Debian 13 mínimo con arranque directo a MAME** ([tarea 16](../16-recreativa-mame/DOCUMENTACION.md)). Batocera se descarta:

| Criterio | Debian 13 + MAME (`Recreativa-1GB`) | Batocera 43.1 (`Batocera`) | Gana |
|---|---|---|---|
| Hardware que pide el fabricante | Funciona con 1 GB | Su guía pide **2 GB mínimo** en VM | Debian |
| Tiempo hasta poder jugar | **7,1 s** ± 0,4 (MAME ya abierto) | 12,9 s ± 0,1 hasta el menú (optimizado), y luego hay que elegir el juego | Debian |
| RAM usada | **400 MB** con MAME y el juego abiertos | **554 MB solo con el menú**, sin juego, y ya tirando de swap (31 MB) | Debian |
| Velocidad de MAME (`-bench`) | gridlee **934 %**, robby **685 %** | gridlee 818 %, robby 666 % | Debian (o empate en robby) |
| Procesos | 101 | 137 | Debian |
| Seguridad de fábrica | `sudo` con usuario propio, root sin acceso, SSH solo con clave | root/`linux` mientras no se active *Enforce security*; la contraseña de root se guarda **en texto plano** en `/boot/batocera-boot.conf` y se ve en el menú | Debian |
| Actualizaciones de seguridad | `apt` con `unattended-upgrades` (a las 4:30-5:00) | Imagen completa, a mano desde el menú | Debian |
| Facilidad para el cliente | Arranca directo al juego, sin menú | Menú bonito, muchos emuladores, mandos configurados solos | Batocera |
| Reproducibilidad | Preseed + `instalar-arcade.sh` | Imagen + `optimizar-batocera.sh` | Empate |

**Por qué:** con 1 GB, Batocera ya ocupa más de la mitad de la RAM **sin haber abierto ningún juego** y empieza a usar swap;
al lanzar MAME (unos 300 MB más) se queda al límite. Debian hace lo mismo con 400 MB **con el juego abierto**, llega antes a
la partida y MAME va igual o más rápido. Además, su seguridad por defecto es la que pide el enunciado; la de Batocera hay que
arreglarla a mano y aun así deja la contraseña en claro. Lo que aporta Batocera (menú, muchos sistemas) no lo pide el reto.

> Debian se midió **sin optimizar** (las medidas de "después" en 1 GB son de la tarea 17). Aun así gana: la optimización
> de la tarea 17 solo puede ampliar la diferencia.

## 2. Método

- **Las dos VM con 1 núcleo y 1 GB**, en el mismo PC, **una sola VM encendida cada vez** (el ServidorERP apagado).
- **3 muestras con reinicio completo** antes y 3 después de optimizar Batocera; se da la media ± la desviación típica.
- Batocera: [`medir-batocera.sh`](medir-batocera.sh) (como root, por SSH, justo tras arrancar). Espera a EmulationStation,
  deja 20 s para que el sistema se asiente y mide: segundo en que se abre el menú (`/proc/<pid>/stat`), RAM usada (`free -m`),
  RAM del menú, procesos, scripts de inicio, disco y `mame -bench 30` de **gridlee** y **robby** (30 s emulados sin límite
  de velocidad; 100 % = velocidad de la máquina original).
- Debian: [`medir-rendimiento.sh`](../17-rendimiento-mame/medir-rendimiento.sh) de la tarea 17, con las mismas medidas.
  Datos del 23/10: [`rendimiento-1gb.csv`](../17-rendimiento-mame/evidencias/rendimiento-1gb.csv).
- **Diferencias entre las dos medidas, a tener en cuenta:** en Debian la RAM se mide **con MAME abierto** (es su
  *frontend*); en Batocera, **solo con el menú** (el juego aún no está abierto). Por eso la comparación de RAM favorece
  a Batocera, y aun así pierde. El `-bench` de Batocera se ejecuta con el menú abierto detrás, como pasaría al jugar.

## 3. Resultados de Batocera

Datos brutos: [`evidencias/rendimiento-batocera.csv`](evidencias/rendimiento-batocera.csv).

| Medida | Antes | Después | Cambio |
|---|---|---|---|
| Menú abierto a los | 20,44 s ± 0,20 | **12,87 s ± 0,07** | **−37 %** |
| RAM usada (solo menú) | 553 MB ± 24 | 554 MB ± 24 | igual |
| RAM del menú (EmulationStation) | 215 MB | 217 MB | igual |
| Procesos | 147 | 137 | −7 % |
| Scripts de inicio | 62 | 62 | — (se desactivan por configuración, no se borran) |
| MAME gridlee | 837 % ± 13 | 818 % ± 19 | −2 % (dentro del ruido) |
| MAME robby | 715 % ± 9 | 666 % ± 22 | **−7 %** |

**Interpretación:**
- Quitar el vídeo de arranque es lo que más se nota: casi **8 s menos** hasta el menú.
- La RAM no baja: lo que se quita (Kodi, Bluetooth) no estaba cargado en memoria, solo arrancaba bajo demanda.
- Tras optimizar ya hay **31 MB en swap** solo con el menú ([`batocera-despues-memoria.txt`](evidencias/batocera-despues-memoria.txt)).
- MAME va **algo más lento** después, sobre todo robby. La causa más probable es `zramswap`: comprimir y descomprimir memoria
  gasta CPU, y con un único núcleo se le quita a MAME. Aun así va a más de 6 veces la velocidad real.

## 4. Lo que se hizo en Batocera

| Paso | Resultado |
|---|---|
| Imagen | `batocera-x86_64-43.1-20260529.img.gz` (4,3 GB) del mirror oficial. **MD5 verificado**: `0c365dc3c17b05a4b276c579168b01da`. Los mirrors limitan cada conexión a ~270 KB/s; se descargó en 24 trozos en paralelo (10 min) |
| VM | `Batocera`: **1 núcleo, 1 GB**, *VMSVGA + 3D + 256 MB de vídeo*, disco convertido con `VBoxManage convertfromraw` y ampliado a 32 GB, SSH en `127.0.0.1:2225` (con clave) |
| Arranque | ✅ Muestra EmulationStation ([captura](evidencias/batocera-01-menu.png)) |
| MAME | MAME **0.285** propio (`/usr/bin/mame/mame`). Las 5 ROMs legales en `/userdata/roms/mame`: `5 romsets found, 5 were OK` |
| Optimización y endurecimiento | [`optimizar-batocera.sh`](optimizar-batocera.sh) · log: [`salida-optimizar-batocera.log`](evidencias/salida-optimizar-batocera.log) · [captura](evidencias/batocera-05-tras-optimizar.png) |

Qué cambia `optimizar-batocera.sh` (todas las claves se comprobaron antes en `/etc/init.d` de la propia VM):

| Cambio | Por qué |
|---|---|
| `system.security.enabled=1` | Sin esto, root y Samba usan siempre `linux` (`/etc/init.d/S35securepasswd`) |
| Kodi desactivado | Centro multimedia que la recreativa no usa |
| Sin vídeo ni sonido de arranque | Retrasaban el menú casi 8 s |
| Sin música de fondo | CPU en un único núcleo |
| Bluetooth y mandos de PS3 desactivados | El stick es USB (tarea 16) |
| `zramswap` activado | Swap comprimida en RAM (482 MB) para no quedarse sin memoria |
| **No se toca:** SSH y las actualizaciones | SSH sirve para administrar; las actualizaciones, para los parches |

## 5. Incidencias

| # | Incidencia | Solución |
|---|---|---|
| 1 | **Pantalla negra** con el vídeo por defecto | *VMSVGA + aceleración 3D + 256 MB de vídeo*, como dice la guía de Batocera para VM |
| 2 | **Batocera pide 2 GB como mínimo en VM** ("Memory: Minimum 2GB (2048MB) required", https://wiki.batocera.org/_export/xhtml/run_batocera_in_vm) | Se probó igualmente con 1 GB, que es lo que tiene el cliente. Arranca, pero usa swap solo con el menú (sección 3) |
| 3 | **Seguridad de fábrica floja** ([captura](evidencias/batocera-04-seguridad-de-fabrica.png)): con *Enforce security* desactivado, root es siempre `linux`, se ve en el menú y vale también para Samba | `system.security.enabled=1`. Al activarlo, Batocera genera una contraseña aleatoria de **solo 8 caracteres**. `batocera-config setRootPassword` **no hace nada si la seguridad está desactivada**, y la contraseña queda **en texto plano** en `/boot/batocera-boot.conf` (`/etc/shadow` se regenera en cada arranque desde ahí). Es una razón más para descartar Batocera |
| 4 | La contraseña de root propia (de KeePassXC) **no se ha puesto** en la VM: se descartó Batocera antes. Queda la aleatoria de 8 caracteres | Si algún día se usa: `read -rs P && batocera-config setRootPassword "$P"; unset P; reboot` |
| 5 | El primer `medir-batocera.sh` dejó el benchmark vacío: `Could not initialize SDL No available video device` | El MAME de Batocera necesita la pantalla X aunque sea con `-bench`: se ejecuta con `DISPLAY=:0.0`. La fila fallida se apartó en la VM (`rendimiento-fallido-sin-bench.csv`) y no cuenta |
| 6 | El primer intento de reiniciar por SSH no reiniciaba: el `reboot` se cortaba al cerrar la sesión, y el SSH de Batocera tarda ~5 s en responder | Se lanza con `nohup setsid` y se comprueba que el *uptime* ha bajado antes de medir |

## 6. Pendiente
- [ ] Tarea 17 (Eneko.P): medidas de "después" de Debian en la VM de 1 GB. **Bloqueado:** no se conoce la contraseña de
  `tecnico` en `Recreativa-1GB` (la de la tarea 16 es de la VM de 2 núcleos): hay que ponerle una nueva desde la consola
  y guardarla en KeePassXC.
- [ ] Tarea 53 (Eneko.S): instalar Debian en el equipo real con el preseed de la tarea 16.
