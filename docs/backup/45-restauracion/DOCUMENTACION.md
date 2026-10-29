# Tarea 45 · Prueba de restauración con evidencias

**Responsable:** Iker · **Fecha:** 22/10/2026 · **Depende de:** 44
**Estado:** ✅ Restauración aislada hecha en máquina virtual (`ServidorERP`), repetida el 27/10/2026 con la BD ya en el RAID · ⏳ Falta la restauración en una máquina nueva (sección 6)


> El paso a paso completo de esta restauración, para un técnico nuevo, está en la documentación final ([tarea 48](../48-documentacion-final-restauracion.md)). Las pruebas y las evidencias son las de este documento.

## 1. Resultado
Se ha restaurado la copia del **disco USB externo**, que es la copia que estaría fuera del local, en un **entorno aislado**.
**Las 16 comprobaciones coinciden** con producción y el Odoo restaurado **arranca y deja entrar**.

| | |
|---|---|
| **Tiempo de restauración medido** (con el servidor ya instalado) | **46 s** |
| **RTO real** (servidor perdido: instalar uno nuevo y restaurar) | **Sin medir.** Los 46 s no incluyen reinstalar Debian, Docker y Odoo, que es lo que pasaría si se pierde el servidor (sección 5). Pendiente: repetir la prueba en una VM nueva y dar ese tiempo como RTO |
| **RPO** (datos que se pueden perder como máximo) | Hasta 24 h con la copia diaria. En la prueba, la copia tenía 6 min |
| **Repetida el 27/10/2026** (BD ya en el RAID, tarea 43; copia del RAID) | **16 comprobaciones OK**, Odoo restaurado con login 200, **63 s**; la copia tenía 101 min ([log](evidencias/restauracion-raid-2026-10-27.log)). La copia ya lleva también `almi_chain` (tarea 44), pero el script solo compara la base de Odoo (`tienda`) |
| Producción durante la prueba | Sin tocar: sigue funcionando, solo existe la base `tienda` y nadie se conectó desde la prueba |

## 2. Cómo se hace
Script: [`probar-restauracion.sh`](probar-restauracion.sh). Es repetible y se recomienda **una vez al mes**: una copia que nunca se ha probado a restaurar no es una copia.
```bash
sudo ./probar-restauracion.sh usb     # o "raid"
```

```
          ┌──────────── PRODUCCIÓN (no se toca) ────────────┐
          │  odoo-odoo-1 ──► odoo-db-1 (base "tienda")       │──┐ solo lectura, para comparar
          └──────────────────────────────────────────────────┘  │
                                                                 ▼
 USB ─► restic restore ─► /srv/datos/prueba-restauracion ─► comparación
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

## 6. Pendiente: restaurar en una máquina nueva

La prueba de la sección 3 se hizo **en el mismo servidor**, con Docker, las imágenes y la configuración ya instaladas. Si el servidor se pierde, nada de eso existe. Para medir el RTO de verdad:

1. Crear una VM nueva, vacía, con el preseed del servidor (tarea 33) y cronometrar desde ese momento.
2. Seguir el plan de la sección 5 con el USB `BACKUP_USB` y la contraseña sacada de KeePassXC (no de un fichero del técnico).
3. Parar el cronómetro cuando un cajero pueda entrar en el TPV y la última venta de la copia aparezca en Odoo.
4. Guardar el log como evidencia y poner ese tiempo como **RTO** en la tabla de la sección 1, en LOGICA_RETO y en el Anexo II.
