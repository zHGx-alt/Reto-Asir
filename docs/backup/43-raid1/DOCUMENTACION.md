# Tarea 43 · RAID 1 y simulación de fallo

**Responsable:** Iker (hecha por Iker; antes estaba a nombre de Eneko.P) · **Fecha:** 22/10/2026
**Estado:** ✅ Hecha en máquina virtual (`ServidorERP`): RAID, simulación de fallo y, desde el 27/10/2026, **la base de datos en el RAID**, con la avería repetida con Odoo funcionando (sección 7)

## 1. Resultado
- RAID 1 por software (`mdadm`) con dos discos de 5 GB, montado en **`/srv/datos`**. Ahí están las copias de seguridad de la tarea 44 y **los datos vivos**: la base de datos de PostgreSQL y los adjuntos de Odoo (sección 7).
- Se simuló la **avería de un disco**: los datos siguieron disponibles y se podía seguir escribiendo.
- Se **cambió el disco** por uno nuevo y el espejo se **reconstruyó en 27 s**, sin perder ni un byte (comprobado con SHA-256).
- El servidor **arranca bien con el RAID degradado** y, después de reparado, **vuelve solo** en cada reinicio.

## 2. Por qué RAID 1
| | RAID 0 | **RAID 1** | RAID 5 |
|---|---|---|---|
| Discos mínimos | 2 | **2** | 3 |
| Aguanta la avería de un disco | ❌ | ✅ | ✅ |
| Capacidad útil con 2 discos | 100 % | **50 %** | — |
| Complejidad y coste | bajos | **bajos** | más discos y más CPU |

Para una tienda pequeña con 2 discos, RAID 1 es lo más sencillo que protege frente a la avería de un disco.

> ⚠️ **Un RAID NO es una copia de seguridad.** Si alguien borra un fichero, o un virus lo cifra, el RAID lo borra o lo cifra
> **en los dos discos a la vez**. Por eso hace falta además el backup 3-2-1 (tarea 44).

## 3. Montaje
| Disco | Puerto SATA | En Linux | Papel |
|---|---|---|---|
| `ServidorERP.vdi` (30 GB) | 0 | `sda` | Sistema (no forma parte del RAID) |
| `raid-disco1.vdi` (5 GB) | 2 | `sdb` | RAID, miembro 0 |
| `raid-disco2.vdi` (5 GB) | 3 | `sdc` | RAID, miembro 1 → **el disco "averiado"** |
| `raid-repuesto.vdi` (5 GB) | 3 | `sdc` | El disco nuevo que sustituye al averiado |

Script: [`crear-raid1.sh`](crear-raid1.sh). Por seguridad, **solo continúa si los dos discos están vacíos y ninguno es el del sistema**.
```bash
sudo ./crear-raid1.sh /dev/sdb /dev/sdc
```
Qué hace:
1. Instala `mdadm` 4.4.
2. `mdadm --create /dev/md0 --level=1 --raid-devices=2`.
3. Formatea en `ext4` y lo monta en `/srv/datos` por **UUID** en `/etc/fstab`, con `nofail` para que el servidor arranque aunque falle el RAID.
4. Añade el array a `/etc/mdadm/mdadm.conf` y regenera el `initramfs`.
5. Activa `mdmonitor`, que avisa (journal y correo de root) si un disco falla.

Log: [`evidencias/02-crear-raid.log`](evidencias/02-crear-raid.log).

## 4. Simulación de fallo, paso a paso

| # | Paso | Comando | Resultado | Evidencia |
|---|---|---|---|---|
| 1 | Datos de prueba | `dd` de 200 MB aleatorios + un texto, con su huella `sha256sum` | 2 ficheros, huellas guardadas | [03](evidencias/03-datos-de-prueba.txt) |
| 2 | **Avería** de `sdc` | `mdadm /dev/md0 --fail /dev/sdc` | `[2/1] [U_]`, `State: clean, degraded`. Kernel: *"Disk failure on sdc… Operation continuing on 1 devices"* | [04](evidencias/04-fallo-disco.txt) |
| 3 | ¿Datos bien? | `sha256sum -c` | ✅ Todas las sumas coinciden | [04](evidencias/04-fallo-disco.txt) |
| 4 | ¿Se puede escribir? | Escribir un fichero nuevo | ✅ Sí, y se guarda su huella | [04](evidencias/04-fallo-disco.txt) |
| 5 | Quitar el disco del RAID | `mdadm /dev/md0 --remove /dev/sdc` | *"hot removed /dev/sdc"* | [04](evidencias/04-fallo-disco.txt) |
| 6 | **Sacar el disco** | Desconectarlo del puerto SATA 3 en VirtualBox | `sdc` desaparece del sistema | [05](evidencias/05-discos-tras-cambio.txt) |
| 7 | Arrancar degradado | Reinicio con un solo disco | ✅ `[U_]` y `/srv/datos` montado | [07](evidencias/07-arranque-degradado.txt) |
| 8 | **Disco nuevo** | Conectarlo al puerto 3; `blkid` confirma que está vacío | Aparece como `sdc` | [08](evidencias/08-reconstruccion.txt) |
| 9 | Reconstruir | `mdadm /dev/md0 --add /dev/sdc` | `recovery` a 182 MB/s, terminado en **27 s** → `[2/2] [UU]`, `State: clean` | [08](evidencias/08-reconstruccion.txt) |
| 10 | ¿Datos bien? | `sha256sum -c` | ✅ Los **3** ficheros coinciden, incluido el escrito en el paso 4 | [08](evidencias/08-reconstruccion.txt) |
| 11 | Reinicio final | `systemctl reboot` | ✅ `[UU]`, montado, datos bien, `mdmonitor` activo y Odoo con HTTP 200 | [09](evidencias/09-tras-reinicio.txt) |

## 5. Procedimiento para la tienda: "ha fallado un disco"
1. Mirar el estado: `cat /proc/mdstat`. Si sale `[U_]` o `[_U]`, el RAID está degradado. El servidor sigue funcionando.
2. Ver qué disco falla: `sudo mdadm --detail /dev/md0` (aparece `faulty`).
3. Quitarlo del RAID: `sudo mdadm /dev/md0 --remove /dev/sdX`.
4. Apagar, cambiar el disco por uno **igual o más grande** y encender.
5. Comprobar con `lsblk` y `sudo blkid -p /dev/sdX` que el disco nuevo está vacío.
6. Añadirlo: `sudo mdadm /dev/md0 --add /dev/sdX`. Esperar a que `cat /proc/mdstat` vuelva a `[UU]`.

## 6. Incidencias

| # | Incidencia | Causa | Solución |
|---|---|---|---|
| 1 | No se pudo conectar el primer disco de repuesto en caliente: `The machine is not mutable` | VirtualBox no deja marcar un puerto como "conexión en caliente" con la VM encendida | — |
| 2 | Después, `medium is already associated` aunque el puerto aparecía vacío | Fallo de VirtualBox 7.0: el disco quedó "a medias" asociado a la VM | Se usó un disco de repuesto **nuevo** (`raid-repuesto.vdi`) en el puerto 3, que sí admite conexión en caliente. Ese mismo fallo sirvió para probar el arranque con el RAID degradado (paso 7). |
| 3 | `mdadm: stat failed for /dev/sdd` | El disco de la incidencia 2 desapareció del sistema justo antes de añadirlo | Ver la incidencia 2. El RAID siguió degradado y sin perder datos. |

## 7. La base de datos en el RAID (27/10/2026)

El enunciado dice: «Esta BD **se almacenará en un dispositivo redundante**». Hasta el 27/10 el RAID solo guardaba las copias:
PostgreSQL y los adjuntos de Odoo estaban en los volúmenes de Docker, en `sda`, el disco del sistema, **fuera del RAID**.

### 7.1 Qué se mueve y por qué solo los volúmenes
La primera idea era mover todo `/var/lib/docker` al RAID, pero **no cabe**: ocupaba **6097 MB** y el RAID tenía **4454 MB**
libres (son discos de 5 GB). Casi todo eran **imágenes** de Docker (Odoo, PostgreSQL), que se vuelven a descargar y no hace
falta proteger. Lo que hay que proteger son los **volúmenes**: la base de datos (`odoo_odoo-db-data`) y los adjuntos
(`odoo_odoo-web-data`), que ocupaban **339 MB**.

Script: [`mover-docker-al-raid.sh`](mover-docker-al-raid.sh). Si ya está hecho, solo comprueba.
```bash
sudo ./mover-docker-al-raid.sh
```
1. Comprueba que el RAID está montado, sano (`[UU]`) y con el doble del sitio que ocupan los volúmenes.
2. Hace una copia de seguridad justo antes (`backup-odoo`, tarea 44).
3. Para Odoo y Docker y copia `/var/lib/docker/volumes` a `/srv/datos/docker-volumes` con `rsync -aHAX`.
4. Monta esa carpeta sobre `/var/lib/docker/volumes` (montaje *bind* en `/etc/fstab`, que exige `/srv/datos`), y Docker
   tiene `RequiresMountsFor=/srv/datos /var/lib/docker/volumes`: **si el RAID no está, Docker no arranca**, en vez de
   arrancar Odoo con una base de datos vacía.
5. Arranca y comprueba. Los volúmenes antiguos quedan en `/var/lib/docker/volumes.antiguo` (se borran a mano pasados unos días).

El script de copias busca la ruta con `docker volume inspect`, así que no hay que cambiarlo: la ruta es la misma.

### 7.2 Resultados
| # | Prueba | Resultado | Evidencia |
|---|---|---|---|
| 1 | Mover los volúmenes | ✅ `/var/lib/docker/volumes` → `/dev/md0[/docker-volumes]`; contenedores en marcha; login de Odoo **200** | [10](evidencias/10-bd-al-raid.log) |
| 2 | **Avería con Odoo funcionando** ([`simular-fallo-con-odoo.sh`](simular-fallo-con-odoo.sh)) | ✅ `sdc` marcado como averiado → `[U_]`, `clean, degraded`. Odoo sigue respondiendo (200) | [11](evidencias/11-fallo-con-odoo.log) |
| 3 | ¿Se guardan ventas con un disco roto? | ✅ El script crea una venta con el propio Odoo (`odoo shell`): **S00007** confirmada; pedidos de venta de 6 a 7; `CHECKPOINT` de PostgreSQL sin errores | [11](evidencias/11-fallo-con-odoo.log) |
| 4 | Cambio de disco y reconstrucción | ✅ `--remove`, `--add` y **reconstruido en 30 s** → `[UU]`, `clean`; la venta sigue ahí | [11](evidencias/11-fallo-con-odoo.log) |
| 5 | Reinicio del servidor | ✅ RAID `[UU]`, `/srv/datos` y los volúmenes montados desde `md0`, Docker activo, Odoo 200, ningún servicio fallido | [12](evidencias/12-tras-reinicio-bd-en-raid.txt) |

**Pendiente:** repetir la prueba de la tarea 45 (restauración) ahora que la BD está en el RAID, y borrar
`/var/lib/docker/volumes.antiguo` cuando haya pasado una semana sin problemas.

**Las copias no pueden quedarse solo en el mismo RAID:** si el RAID entero se pierde (fallo de la controladora, borrado,
incendio), se pierden a la vez los datos y la copia 2. Por eso la copia 3 (USB fuera del local, y mejor aún S3) es la que de
verdad protege; ver la tarea 44.
