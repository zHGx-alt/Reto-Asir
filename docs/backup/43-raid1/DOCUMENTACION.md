# Tarea 43 · RAID 1 y simulación de fallo

**Responsable:** Iker (hecha por Iker; antes estaba a nombre de Eneko.P) · **Fecha:** 22/10/2026
**Estado:** ✅ RAID y simulación de fallo hechos en máquina virtual (`ServidorERP`) · ⚠️ **La base de datos todavía no está en el RAID** (sección 7)

## 1. Resultado
- RAID 1 por software (`mdadm`) con dos discos de 5 GB, montado en **`/srv/datos`**. Ahí van las copias de seguridad de la tarea 44 y **tienen que ir también los datos vivos** de PostgreSQL y Odoo (sección 7: todavía no están).
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

## 7. Pendiente: la base de datos tiene que estar en el RAID

El enunciado dice: «Esta BD **se almacenará en un dispositivo redundante**». Ahora mismo el RAID (`/srv/datos`) solo guarda las copias: PostgreSQL y los adjuntos de Odoo siguen en los volúmenes de Docker (`/var/lib/docker/volumes/...`), que están en `sda`, el disco del sistema, **fuera del RAID**. Si falla `sda`, la base de datos viva se pierde y hay que restaurar la última copia (hasta 24 h de datos). La simulación de la sección 4 no lo detecta porque el disco que se «rompió» era del RAID, no el del sistema.

**Cómo se corrige:** mover el directorio de datos de Docker al RAID. Así quedan en el espejo las bases `tienda` y `almi_chain` y los adjuntos.

**Con el script (recomendado):** [`mover-docker-al-raid.sh`](mover-docker-al-raid.sh) hace todo lo de abajo y lo comprueba: mira que el RAID esté sano y tenga sitio, hace una copia antes, mueve los datos, configura Docker para que arranque después del RAID y verifica que Odoo responde. Si ya está movido, solo comprueba (sintaxis comprobada con `bash -n`; falta ejecutarlo en la VM).

```bash
sudo ./mover-docker-al-raid.sh
```

**A mano**, con Odoo parado y una copia recién hecha (tarea 44):

```bash
sudo systemctl start backup-odoo          # copia justo antes del cambio
cd /opt/odoo && sudo docker compose down
sudo systemctl stop docker docker.socket
sudo rsync -aHAX /var/lib/docker/ /srv/datos/docker/
echo '{ "data-root": "/srv/datos/docker" }' | sudo tee /etc/docker/daemon.json
```

Docker tiene que arrancar **después** de montar el RAID. En `sudo systemctl edit docker.service`:

```
[Unit]
RequiresMountsFor=/srv/datos
```

```bash
sudo systemctl daemon-reload && sudo systemctl start docker
sudo docker info --format '{{.DockerRootDir}}'    # debe decir /srv/datos/docker
cd /opt/odoo && sudo docker compose up -d
```

Cuando Odoo funcione igual (login y una venta de prueba), borrar el directorio antiguo con `sudo rm -rf /var/lib/docker.old` (antes, `sudo mv /var/lib/docker /var/lib/docker.old` para tenerlo de respaldo unos días). El script de copias ya busca la ruta del volumen con `docker volume inspect`, así que no hay que cambiarlo.

La otra opción es instalar el sistema entero sobre el RAID 1 (el instalador de Debian lo permite), que protege también el sistema operativo. Para el reto basta con mover los datos.

**Después hay que repetir:**
- La simulación de fallo (sección 4) **con Odoo funcionando durante el fallo**: hacer una venta con un disco del RAID quitado y comprobar que se guarda.
  Script: [`simular-fallo-con-odoo.sh`](simular-fallo-con-odoo.sh). Comprueba que la BD está en el RAID, marca como averiado
  un disco, mira que Odoo responde, **espera a que se haga una venta** y comprueba que se ha guardado (recuento de pedidos y
  facturas en `tienda` + `CHECKPOINT` de PostgreSQL), vuelve a añadir el disco y espera a que el espejo vuelva a `[UU]`.
  ```bash
  sudo ./simular-fallo-con-odoo.sh 2>&1 | tee fallo-con-odoo.log
  ```
- La prueba de la tarea 45.

**Las copias no pueden quedarse solo en el mismo RAID:** si el RAID entero se pierde (fallo de la controladora, borrado, incendio), se pierden a la vez los datos y la copia 2. Por eso la copia 3 (USB fuera del local, y mejor aún S3) es la que de verdad protege; ver la tarea 44.
