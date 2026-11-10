# Tarea 45 · Prueba de restauración con evidencias

**Responsable:** Iker · **Fecha:** 22/10/2026 · **Depende de:** 44
**Estado:** ✅ Restauración aislada hecha en máquina virtual (`ServidorERP`), repetida el 27/10/2026 con la BD ya en el RAID · ✅ Recuperación en una máquina nueva el 10/11/2026: **RTO ≈ 14 min** (sección 6)


> El paso a paso completo de esta restauración, para un técnico nuevo, está en la documentación final ([tarea 48](../48-documentacion-final-restauracion.md)). Las pruebas y las evidencias son las de este documento.

## 1. Resultado
Se ha restaurado la copia del **disco USB externo**, que es la copia que estaría fuera del local, en un **entorno aislado**.
**Las 16 comprobaciones coinciden** con producción y el Odoo restaurado **arranca y deja entrar**.

| | |
|---|---|
| **Tiempo de restauración medido** (con el servidor ya instalado) | **46 s** |
| **RTO real** (servidor perdido: instalar uno nuevo y restaurar) | **832 s ≈ 14 min** (10/11/2026): de una VM vacía a Odoo por HTTPS con los datos del USB, con [`recuperar-servidor-nuevo.sh`](recuperar-servidor-nuevo.sh). Detalle en la sección 6 ([log](evidencias/rto-maquina-nueva-2026-11-10.log)) |
| **RPO** (datos que se pueden perder como máximo) | Hasta 24 h con la copia diaria. En la prueba, la copia tenía 6 min |
| **Repetida el 27/10/2026** (BD ya en el RAID, tarea 43; copia del RAID) | **16 comprobaciones OK**, Odoo restaurado con login 200, **63 s**; la copia tenía 101 min ([log](evidencias/restauracion-raid-2026-10-27.log)). La copia ya lleva también `almi_chain` (tarea 44), pero el script solo comparaba la base de Odoo (`tienda`) |
| **Repetida el 04/11/2026** (tarea 60; laboratorio montado desde cero con los scripts 43 y 44) | El script restaura y compara ahora también **`almi_chain`**: sus roles (`globals.sql`), las 13 tablas, una huella de las filas de cada tabla, clientes, platos, facturas, importe de las líneas y los 48 permisos de `rol_aplicacion` y `rol_lectura`. **Desde S3: 23 comprobaciones OK en 166 s** ([log](evidencias/restauracion-s3-2026-11-04.log)); **desde el RAID: 23 OK en 68 s** ([log](evidencias/restauracion-raid-almi-chain-2026-11-04.log)) |
| Producción durante la prueba | Sin tocar: sigue funcionando, solo existe la base `tienda` y nadie se conectó desde la prueba |

## 2. Cómo se hace
Script: [`probar-restauracion.sh`](probar-restauracion.sh). Es repetible y se recomienda **una vez al mes**: una copia que nunca se ha probado a restaurar no es una copia.
```bash
sudo ./probar-restauracion.sh usb     # o "raid", o "s3" (lee las claves de /root/.config/backup-odoo/s3.env)
```

```
          ┌──────────── PRODUCCIÓN (no se toca) ────────────┐
          │  odoo-odoo-1 ──► odoo-db-1 (base "tienda")       │──┐ solo lectura, para comparar
          └──────────────────────────────────────────────────┘  │
                                                                 ▼
 USB / RAID / S3 ─► restic restore ─► /srv/datos/prueba-restauracion ─► comparación
                                 │                                 ▲
          ┌──────── red Docker "restauracion" (interna) ───────────┤
          │  pg-prueba-restauracion ◄── pg_restore del volcado     │
          │  odoo-prueba-restauracion (127.0.0.1:8070, sin cron) ──┘ login de admin
          └────────────────────────────────────────────────────────┘
                       al terminar se borra todo
```

1. **Elegir la copia:** monta el USB por su etiqueta y busca la última instantánea.
2. **Restaurar los ficheros:** `restic restore latest`, 922 ficheros y directorios (21,8 MB) en menos de 1 s.
3. **Restaurar la base de datos** en un **PostgreSQL temporal y aislado**: `createdb` + `pg_restore --exit-on-error`.
4. **Comparar** producción con lo restaurado (tabla de abajo).
5. **Arrancar un Odoo temporal** con lo restaurado, sin tareas programadas para que no envíe correos ni haga nada por su cuenta, y **entrar como admin**.
6. **Medir el RTO y limpiar**: se borran los contenedores, la red y los ficheros temporales. La limpieza se hace también si el script falla a medias (`trap`).

## 3. Evidencias
Log completo: [`evidencias/restauracion-desde-usb.log`](evidencias/restauracion-desde-usb.log).

| Dato | Producción | Restaurado | |
|---|---|---|---|
| Clientes y contactos | 10 | 10 | ✅ |
| Productos | 6 | 6 | ✅ |
| Pedidos de venta | 4 | 4 | ✅ |
| Facturas validadas | 2 | 2 | ✅ |
| Total facturado | 24,20 € | 24,20 € | ✅ |
| Última factura | INV/2026/00002 | INV/2026/00002 | ✅ |
| Apuntes contables | 10 | 10 | ✅ |
| Puntos de venta | TPV 1, TPV 2 | TPV 1, TPV 2 | ✅ |
| Usuarios activos | admin, gerente, cajero1, cajero2 | igual | ✅ |
| Adjuntos: nº de ficheros | 466 | 466 | ✅ |
| Adjuntos: huella SHA-256 de todo el contenido | `8bf6c4930420537d` | `8bf6c4930420537d` | ✅ |
| `docker-compose.yml` / `.env` / `odoo.conf` | huellas | idénticas | ✅ |
| Odoo restaurado: `/web/login` | — | HTTP 200 | ✅ |
| Odoo restaurado: login de admin | — | uid 2 | ✅ |

## 4. Incidencias (y lo que se aprendió)
| # | Incidencia | Causa | Solución |
|---|---|---|---|
| 1 | La primera versión daba "correcta" pero **solo comparaba 1 dato de 9** | `docker compose exec` lee la entrada estándar y se "comía" la lista de comprobaciones del bucle `while read` | `</dev/null` en cada llamada. **Lección: no fiarse de un ✅ sin mirar qué se ha comprobado.** |
| 2 | Al restaurar como `tienda_restaurada` en el PostgreSQL de **producción**, el **Odoo de producción se conectó a la copia** | El programador de tareas de Odoo recorre todas las bases del servidor PostgreSQL, aunque `dbfilter` no deje entrar por web | Restaurar en un **PostgreSQL temporal y aislado**, en una red Docker interna. Se comprobó que en producción solo queda la base `tienda`. |
| 3 | `dropdb: database is being accessed by other users` | Consecuencia de la incidencia 2 | `dropdb --force` para limpiar, y el diseño aislado para que no vuelva a pasar |
| 4 | Los contenedores aparecían como "Up Less than a second" | La VM arranca con el reloj 2 h adelantado: VirtualBox le da la hora **local** como si fuera UTC, y luego `timesyncd` la corrige | Cosmético. Arreglo en la próxima parada: `VBoxManage modifyvm ServidorERP --rtc-use-utc on` (y lo mismo en la Recreativa) |

## 5. Plan de recuperación ante un desastre real (servidor destruido)
1. Instalar Debian 13 en el servidor nuevo con [`../../erp/33-odoo-docker/preseed-servidor.cfg`](../../erp/33-odoo-docker/preseed-servidor.cfg).
2. `sudo apt install restic docker.io docker-cli docker-compose` y conectar el USB `BACKUP_USB`.
3. Copiar la contraseña de cifrado (desde el gestor del gerente) a un fichero y restaurar: `restic -r /mnt/usb-backup/restic restore latest --target /`.
4. `cd /opt/odoo && docker compose up -d db` → `createdb tienda` → `pg_restore` del volcado → copiar el *filestore* al volumen → `docker compose up -d`.
5. Comprobar con este mismo script o entrando en `http://<servidor>:8069`.

## 6. Restaurar en una máquina nueva (RTO real, 10/11/2026)

La prueba de la sección 3 se hizo **en el mismo servidor**, con Docker, las imágenes y la configuración ya instaladas. Si el servidor se pierde, nada de eso existe. Para medir el RTO de verdad se partió de una VM vacía.

**Montaje.** VM `RTO-48` nueva en el PC de Adrian (2 CPU, 4 GB, disco de 20 GB, NAT con salida a Internet), instalada con el [preseed del servidor](../../erp/33-odoo-docker/preseed-servidor.cfg). Como «USB» se conectó un **clon** del disco `BACKUP_USB` de la `ServidorERP` del laboratorio (`VBoxManage clonemedium`, con la ServidorERP apagada): la copia original no se toca. La contraseña de restic se pasó en un fichero temporal, como si se sacara de KeePassXC. Todo lo demás lo hace [`recuperar-servidor-nuevo.sh`](recuperar-servidor-nuevo.sh), que es el plan de desastre de la [tarea 48, sección 11](../48-documentacion-final-restauracion.md#11-plan-de-recuperación-ante-un-desastre-real) hecho script:

```bash
sudo ./recuperar-servidor-nuevo.sh /ruta/restic.pass   # instala restic, Docker y Compose; restaura /opt/odoo, las dos bases y los adjuntos; arranca Odoo y el proxy HTTPS
```

| Paso | Tiempo |
|---|---|
| Crear la VM e instalar Debian 13 con el preseed (hasta SSH con clave) | 468 s |
| Conectar el USB (en la VM: apagar, añadir el disco y arrancar; con un USB real es enchufarlo) | 41 s |
| Instalar restic, Docker y Compose (`apt`) | 73 s |
| Restaurar la copia, las bases `tienda` y `almi_chain` y los adjuntos, y arrancar Odoo con el proxy HTTPS | 250 s |
| **Total (RTO)** | **832 s ≈ 14 min** |

**Resultado** ([log](evidencias/rto-maquina-nueva-2026-11-10.log)): `/web/login` da 200 por HTTP en el propio servidor y por **HTTPS** a través del proxy de la tarea 52; `admin` entra (uid 2); están los dos puntos de venta y los dos cajeros; la **última venta** (`TPV Barra 1 - 000007`, 27/10, 1,50 €), las 7 ventas, los 9 clientes y los 20 productos coinciden con la ServidorERP de origen; `almi_chain` vuelve con sus 13 tablas y 8 facturas.

**Qué se aprende:**

- La mitad del tiempo es instalar Debian; casi todo lo demás es **descargar las imágenes** de PostgreSQL 17 y Odoo 19 de Docker Hub (94 s y 151 s). Sin Internet en el local hay que llevar las imágenes en el USB (`docker save`) o el RTO sube.
- El USB se monta **en solo lectura** para no estropear la copia por error. restic necesita entonces `--no-lock`: en el primer intento se quedó reintentando crear su bloqueo en el USB (incidencia corregida en el script; ese tiempo no se cuenta).
- La copia del USB era del 04/11 (la VM del laboratorio estuvo apagada desde entonces): con el servidor encendido cada día, el RPO es de 24 h como máximo.
- **Sin probar:** que un TPV entre en el servidor recuperado. La VM estaba en NAT, fuera de la red `reto-lan` de los TPV; se comprobó el HTTPS desde el propio servidor y que los cajeros existen y están activos.
- Al acabar, el servidor nuevo **aún no hace copias** ni tiene cortafuegos: hay que pasar `instalar-backup.sh` (tarea 44) y `cortafuegos-servidor.sh` (tarea 33). El script lo recuerda al final.
