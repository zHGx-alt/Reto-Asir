# Tarea 16 · Recreativa con Batocera (EN CURSO)

**Responsable:** Iker · **Fecha:** 23/10/2026 · **Estado:** 🟡 En curso: arranca, faltan la optimización y las medidas

El equipo decidió probar **Batocera** como sistema de la recreativa. El enunciado y el plan solo piden MAME en un equipo de
**1 núcleo y 1 GB**; el plan propone "Debian mínimo / Alpine / Lakka". Por eso se mantiene también la versión con Debian
(`../16-recreativa-mame/`) para compararlas con datos.

## Lo hecho
| Paso | Resultado |
|---|---|
| Imagen | `batocera-x86_64-43.1-20260529.img.gz` (4,3 GB) del mirror oficial. **MD5 verificado**: `0c365dc3c17b05a4b276c579168b01da`. Los mirrors limitan cada conexión a ~270 KB/s; se descargó en 24 trozos en paralelo (10 min) |
| VM | `Batocera`: **1 núcleo, 1 GB**, disco convertido con `VBoxManage convertfromraw` y ampliado a 32 GB, SSH en `127.0.0.1:2225` |
| Arranque | ✅ Arranca y muestra EmulationStation ([captura](evidencias/batocera-01-menu.png)) |
| MAME | MAME **0.285** propio (`/usr/bin/mame/mame`). Las 5 ROMs legales en `/userdata/roms/mame`: `5 romsets found, 5 were OK` |
| RAM en reposo | **565 MB usados de 963 MB**, solo con el menú (la Debian con MAME abierto usa ~400 MB) |

## Hallazgos
1. **Batocera pide 2 GB como mínimo en VM** según su propia guía ("Memory: Minimum 2GB (2048MB) required",
   https://wiki.batocera.org/_export/xhtml/run_batocera_in_vm). Con 1 GB arranca, pero hay que comprobar si es usable.
2. **Pantalla negra** con el vídeo por defecto: hacen falta *VMSVGA + aceleración 3D + 256 MB de vídeo* (lo dice la misma guía).
3. **Seguridad de fábrica floja** ([captura](evidencias/batocera-04-seguridad-de-fabrica.png)):
   - Mientras *Enforce security* esté desactivado, la contraseña de root es siempre **`linux`** (`/etc/init.d/S35securepasswd`)
     y se ve en el menú. La misma contraseña vale para la carpeta compartida por Samba.
   - El SSH viene activado (tarda en responder en el primer arranque mientras genera las claves).
4. Teclado en el menú: **Espacio** = Start (menú), **Enter** = elegir, **Esc** = atrás.

## Pendiente
- [ ] 3 medidas de "antes" (script `medir-batocera.sh` por escribir: menú abierto a los X s, RAM, procesos, `mame -bench`).
- [ ] Endurecer: `batocera-settings-set system.security.enabled 1` + `batocera-config setRootPassword <aleatoria>` (guardada fuera del repo).
- [ ] Optimizar: activar `zramswap`, quitar Kodi y los servicios que no se usan, MAME standalone por defecto, sin vídeo de arranque.
- [ ] 3 medidas de "después" y comparativa con Debian para el Anexo II.
