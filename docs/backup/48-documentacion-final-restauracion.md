# Tarea 48 · Documentación final paso a paso de la restauración

- **Responsable:** Markel
- **Fecha:** 29/10/2026
- **Depende de:** [Tarea 45](45-restauracion/DOCUMENTACION.md) · Prueba de restauración con evidencias. Este documento es el capítulo de restauración de la documentación final (tarea 48): explica los pasos; las pruebas y evidencias son las de la 45
- **Estado:** En curso. Restauración aislada completada; pendiente medir el RTO real en una máquina virtual nueva.

## 1. Objetivo

El objetivo de esta tarea es documentar de forma clara y reproducible la restauración de las copias de seguridad del servidor ERP.

La documentación parte de la prueba realizada en la Tarea 45 y explica:

- Cómo se selecciona la copia de seguridad.
- Cómo se restauran los ficheros y la base de datos.
- Cómo se aísla el entorno de restauración.
- Cómo se inicia temporalmente Odoo.
- Cómo se comparan los datos restaurados con producción.
- Cómo se limpia el entorno al finalizar.
- Cómo se recuperaría el servicio si el servidor quedara destruido.
- Qué prueba falta para calcular el RTO real.

## 2. Resultado general

Se ha restaurado correctamente la copia almacenada en el **disco USB externo**, que representa la copia guardada fuera del local, dentro de un entorno aislado en la máquina virtual `ServidorERP`.

Las comprobaciones realizadas coinciden con el entorno de producción. El Odoo restaurado arranca, muestra la página de acceso y permite iniciar sesión con la cuenta administradora.

| Indicador | Resultado |
|---|---|
| Tiempo medido con el servidor ya preparado | **46 segundos** |
| RTO real | **Pendiente de medir** en una máquina virtual nueva |
| RPO máximo | **24 horas**, al existir una copia diaria |
| Antigüedad de la copia utilizada | **6 minutos** |
| Producción durante la prueba | No se modificó |
| Base existente en producción | Únicamente `tienda` |
| Resultado de las comprobaciones | Coinciden con producción |

> **Importante:** los 46 segundos no representan el RTO real, porque no incluyen la creación de un servidor nuevo ni la instalación de Debian, Docker, Restic y Odoo.

## 3. Entorno de restauración

La prueba se diseñó para no modificar el entorno de producción.

La arquitectura utilizada fue la siguiente:

```text
          ┌──────────── PRODUCCIÓN (no se toca) ────────────┐
          │  odoo-odoo-1 ──► odoo-db-1 (base "tienda")      │──┐
          └──────────────────────────────────────────────────┘  │
                     solo lectura para comparar                 │
                                                                 ▼
 USB ─► restic restore ─► /srv/datos/prueba-restauracion ─► comparación
                                 │                                 ▲
          ┌──────── red Docker "restauracion" (interna) ──────────┤
          │  pg-prueba-restauracion ◄── pg_restore del volcado     │
          │  odoo-prueba-restauracion                              │
          │  127.0.0.1:8070, sin tareas programadas ───────────────┘
          └─────────────────────────────────────────────────────────┘
                       al terminar se borra todo
```

Los componentes temporales de la prueba son:

- Directorio temporal: `/srv/datos/prueba-restauracion`.
- Red Docker interna: `restauracion`.
- PostgreSQL temporal: `pg-prueba-restauracion`.
- Odoo temporal: `odoo-prueba-restauracion`.
- Puerto local del Odoo restaurado: `127.0.0.1:8070`.

## 4. Elementos incluidos en la copia

La copia de seguridad contiene los elementos necesarios para recuperar el servicio:

- Volcado de la base de datos PostgreSQL.
- Filestore de Odoo.
- Archivo `docker-compose.yml`.
- Archivo `.env`.
- Archivo `odoo.conf`.
- Configuración necesaria para iniciar los contenedores.
- Datos necesarios para verificar la integridad de la restauración.

## 5. Script utilizado

La prueba se automatiza con el script:

```text
probar-restauracion.sh
```

Para probar la copia del disco USB se ejecuta:

```bash
sudo ./probar-restauracion.sh usb
```

Para probar la copia del RAID se ejecuta:

```bash
sudo ./probar-restauracion.sh raid
```

Se recomienda ejecutar esta prueba **una vez al mes**, porque una copia que nunca se ha restaurado no puede considerarse completamente verificada.

## 6. Restauración paso a paso

### 6.1. Conectar y montar el disco externo

1. Conectar el disco USB al servidor.
2. Identificar el dispositivo mediante su etiqueta `BACKUP_USB`.
3. Montar el disco en `/mnt/usb-backup`.
4. Comprobar que existe el repositorio de Restic:

```text
/mnt/usb-backup/restic
```

5. Utilizar el disco únicamente como origen de lectura durante la prueba.

### 6.2. Seleccionar la última instantánea

1. Consultar las instantáneas disponibles en el repositorio.
2. Seleccionar la instantánea más reciente.
3. Comprobar que incluye la base de datos, el filestore y la configuración.

La copia utilizada en la prueba tenía una antigüedad aproximada de **6 minutos**.

### 6.3. Restaurar los ficheros

La última instantánea se restaura con Restic en un directorio temporal:

```bash
restic -r /mnt/usb-backup/restic restore latest \
  --target /srv/datos/prueba-restauracion
```

Resultado de esta fase:

- **922 ficheros y directorios** recuperados.
- Tamaño total aproximado: **21,8 MB**.
- Tiempo de recuperación de los ficheros: **menos de 1 segundo**.

### 6.4. Crear una red Docker aislada

Se crea una red Docker interna llamada:

```text
restauracion
```

Esta red conecta únicamente el PostgreSQL y el Odoo temporales. De esta forma, el Odoo de producción no puede conectarse a la base restaurada.

### 6.5. Crear un PostgreSQL temporal

1. Iniciar el contenedor `pg-prueba-restauracion`.
2. Conectarlo únicamente a la red interna `restauracion`.
3. Crear una base de datos vacía con `createdb`.
4. No crear la base restaurada dentro del PostgreSQL de producción.

### 6.6. Restaurar la base de datos

El volcado se restaura mediante:

```bash
pg_restore --exit-on-error
```

La opción `--exit-on-error` hace que el proceso se detenga si aparece cualquier error, evitando aceptar como válida una restauración incompleta.

### 6.7. Restaurar y comprobar el filestore

1. Copiar el filestore recuperado al volumen temporal utilizado por Odoo.
2. Contar los archivos restaurados.
3. Calcular la huella SHA-256 conjunta.
4. Comparar el número de archivos y la huella con producción.

Resultado:

- Producción: **466 archivos**.
- Restauración: **466 archivos**.
- Huella SHA-256 en ambos casos: `8bf6c4930420537d`.

### 6.8. Iniciar un Odoo temporal

Se inicia el contenedor:

```text
odoo-prueba-restauracion
```

El servicio se publica solo en la interfaz local:

```text
127.0.0.1:8070
```

Las tareas programadas se desactivan para evitar que la copia restaurada:

- Envíe correos.
- Ejecute acciones automáticas.
- Modifique servicios externos.
- Interfiera con producción.

### 6.9. Comprobar la página de acceso

Se abre la dirección:

```text
http://127.0.0.1:8070/web/login
```

El resultado esperado y obtenido es:

```text
HTTP 200
```

### 6.10. Comprobar el inicio de sesión

Se inicia sesión con la cuenta administradora.

El resultado obtenido es:

```text
uid 2
```

Esto confirma que Odoo puede consultar la base restaurada y que la autenticación funciona.

### 6.11. Comparar producción y restauración

El entorno de producción se consulta únicamente en modo lectura. Los valores se comparan con los del entorno restaurado.

Se revisan clientes, productos, pedidos, facturas, total facturado, apuntes contables, puntos de venta, usuarios, adjuntos y archivos de configuración.

### 6.12. Medir el tiempo

El procedimiento automatizado completo tardó:

```text
46 segundos
```

Este tiempo incluye:

- Restauración de los ficheros.
- Restauración de PostgreSQL.
- Inicio del Odoo temporal.
- Comparaciones automáticas.
- Prueba de la página web.
- Prueba del inicio de sesión.

No incluye la instalación de un servidor nuevo.

### 6.13. Limpiar el entorno

Al finalizar se eliminan:

- El PostgreSQL temporal.
- El Odoo temporal.
- La red Docker interna.
- Los ficheros temporales.
- La base temporal de restauración.

El script utiliza `trap` para que la limpieza también se ejecute si la prueba falla a la mitad.

## 7. Evidencias y comprobaciones

El log completo se encuentra en:

```text
evidencias/restauracion-desde-usb.log
```

| Dato | Producción | Restaurado | Resultado |
|---|---:|---:|:---:|
| Clientes y contactos | 10 | 10 | ✅ |
| Productos | 6 | 6 | ✅ |
| Pedidos de venta | 4 | 4 | ✅ |
| Facturas validadas | 2 | 2 | ✅ |
| Total facturado | 24,20 € | 24,20 € | ✅ |
| Última factura | INV/2026/00002 | INV/2026/00002 | ✅ |
| Apuntes contables | 10 | 10 | ✅ |
| Puntos de venta | TPV 1, TPV 2 | TPV 1, TPV 2 | ✅ |
| Usuarios activos | admin, gerente, cajero1, cajero2 | Iguales | ✅ |
| Adjuntos: número de ficheros | 466 | 466 | ✅ |
| Adjuntos: huella SHA-256 | `8bf6c4930420537d` | `8bf6c4930420537d` | ✅ |
| `docker-compose.yml`, `.env` y `odoo.conf` | Huellas originales | Idénticas | ✅ |
| Odoo restaurado: `/web/login` | No aplica | HTTP 200 | ✅ |
| Odoo restaurado: login de admin | No aplica | uid 2 | ✅ |

Las comprobaciones coinciden con el entorno de producción.

## 8. RPO

El RPO indica la cantidad máxima de datos que podrían perderse.

Como la copia se realiza una vez al día, el RPO máximo es:

```text
24 horas
```

En la prueba realizada, la copia tenía una antigüedad de aproximadamente **6 minutos**, por lo que la pérdida potencial de datos era mucho menor que el máximo definido.

## 9. RTO

El RTO indica el tiempo necesario para recuperar el servicio después de una interrupción.

El tiempo medido en el servidor ya preparado fue:

```text
46 segundos
```

Este valor no es todavía el RTO real, porque no incluye:

- Crear una máquina nueva.
- Instalar Debian 13.
- Instalar Docker y Docker Compose.
- Instalar Restic.
- Conectar el disco externo.
- Recuperar la contraseña desde KeePassXC.
- Restaurar completamente Odoo.
- Comprobar el acceso desde un TPV.

El RTO real permanecerá pendiente hasta repetir todo el procedimiento en una máquina virtual vacía.

## 10. Incidencias y soluciones

| # | Incidencia | Causa | Solución y aprendizaje |
|---:|---|---|---|
| 1 | La primera versión indicaba éxito, pero solo comparaba 1 dato de 9 | `docker compose exec` consumía la entrada estándar del bucle `while read` | Añadir `</dev/null` en cada llamada. No confiar únicamente en un ✅; también hay que comprobar cuántas pruebas se ejecutaron. |
| 2 | El Odoo de producción se conectó a la base restaurada | La copia se restauró inicialmente en el PostgreSQL de producción y el programador de Odoo revisa todas las bases disponibles | Restaurar en un PostgreSQL temporal dentro de una red Docker interna. En producción debe existir únicamente la base `tienda`. |
| 3 | `dropdb: database is being accessed by other users` | Odoo mantenía conexiones abiertas con la base restaurada | Utilizar `dropdb --force` para limpiar y evitar el problema mediante el nuevo diseño aislado. |
| 4 | Los contenedores aparecían como `Up Less than a second` | VirtualBox entregaba la hora local como UTC y después `timesyncd` la corregía | Incidencia cosmética. Configurar la VM con `VBoxManage modifyvm ServidorERP --rtc-use-utc on`. Aplicar también a la máquina recreativa si fuera necesario. |

## 11. Plan de recuperación ante un desastre real

Si el servidor queda destruido, se seguirá este procedimiento.

### 11.1. Crear el servidor nuevo

Preparar un servidor físico o una máquina virtual vacía.

### 11.2. Instalar Debian 13

Utilizar el archivo de preconfiguración:

```text
../../erp/33-odoo-docker/preseed-servidor.cfg
```

### 11.3. Instalar las herramientas necesarias

```bash
sudo apt install restic docker.io docker-cli docker-compose
```

### 11.4. Conectar la copia externa

Conectar el disco identificado como:

```text
BACKUP_USB
```

### 11.5. Recuperar la contraseña

Obtener la contraseña de cifrado desde KeePassXC, utilizando el gestor del gerente.

La contraseña no debe depender de un fichero local del servidor destruido ni quedar publicada en la documentación.

### 11.6. Restaurar la última copia

```bash
restic -r /mnt/usb-backup/restic restore latest --target /
```

### 11.7. Iniciar PostgreSQL

```bash
cd /opt/odoo
docker compose up -d db
```

### 11.8. Restaurar la base de datos

1. Crear la base `tienda`.
2. Restaurar el volcado mediante `pg_restore`.
3. Detener el procedimiento si aparece un error.

### 11.9. Restaurar el filestore

1. Copiar el filestore al volumen de Odoo.
2. Revisar propietarios y permisos.
3. Comparar el número de archivos y la huella SHA-256.

### 11.10. Iniciar Odoo

```bash
docker compose up -d
```

### 11.11. Comprobar el servicio

Abrir:

```text
http://<servidor>:8069
```

La recuperación solamente se considera terminada cuando:

- Odoo está disponible.
- Un usuario puede iniciar sesión.
- Los productos y clientes aparecen.
- Funcionan los dos puntos de venta.
- La última venta incluida en la copia está disponible.
- Un cajero puede acceder desde un TPV.

## 12. Restauración pendiente en una máquina nueva

La prueba completada se realizó en el mismo servidor, que ya tenía Docker, las imágenes y la configuración instalados.

Para medir el RTO real se debe repetir la prueba en una máquina virtual completamente nueva.

### Procedimiento pendiente

1. Crear una máquina virtual vacía.
2. Iniciar el cronómetro.
3. Instalar Debian 13 mediante el preseed de la tarea 33.
4. Instalar Restic, Docker, Docker CLI y Docker Compose.
5. Conectar el USB `BACKUP_USB`.
6. Obtener la contraseña desde KeePassXC.
7. Restaurar la última instantánea.
8. Iniciar PostgreSQL.
9. Crear y restaurar la base `tienda`.
10. Restaurar el filestore.
11. Iniciar Odoo.
12. Acceder desde un TPV.
13. Comprobar que aparece la última venta de la copia.
14. Detener el cronómetro.
15. Guardar el log de la prueba.
16. Sustituir el estado pendiente por el RTO medido.
17. Actualizar el RTO en la tabla de resultados, en `LOGICA_RETO` y en el Anexo II.

## 13. Evidencias que deben conservarse

### Evidencias disponibles

- Script `probar-restauracion.sh`.
- Log `evidencias/restauracion-desde-usb.log`.
- Resultado de la restauración de 922 archivos y directorios.
- Comparación de datos entre producción y restauración.
- Huella SHA-256 del filestore.
- Huellas de `docker-compose.yml`, `.env` y `odoo.conf`.
- Respuesta HTTP 200 de `/web/login`.
- Inicio de sesión del administrador con `uid 2`.
- Tiempo medido de 46 segundos.
- Confirmación de que producción no fue modificada.

### Evidencias pendientes

- Log de la recuperación en una máquina virtual nueva.
- Hora de inicio y finalización.
- RTO real.
- Captura o registro de Odoo funcionando en el servidor nuevo.
- Evidencia del TPV accediendo al servicio restaurado.
- Evidencia de la última venta recuperada.

## 14. Lista de comprobación final

- [x] Se ha restaurado la copia del USB externo.
- [x] La restauración se ha realizado en un entorno aislado.
- [x] Producción no se ha modificado.
- [x] PostgreSQL se ha restaurado sin errores.
- [x] El filestore coincide con producción.
- [x] Los archivos de configuración coinciden.
- [x] Odoo responde con HTTP 200.
- [x] El administrador puede iniciar sesión.
- [x] Los datos funcionales coinciden con producción.
- [x] El entorno temporal se elimina al terminar.
- [x] Se ha medido el tiempo en el servidor ya preparado.
- [ ] Se ha repetido la restauración en una máquina nueva.
- [ ] Se ha medido el RTO real.
- [ ] Se ha probado el acceso desde un TPV al servidor recuperado.
- [ ] Se ha actualizado el RTO en `LOGICA_RETO` y en el Anexo II.

## 15. Conclusión

La copia almacenada en el disco USB externo se ha restaurado correctamente dentro de un entorno aislado.

Los datos restaurados coinciden con producción. El filestore conserva el mismo número de archivos y la misma huella SHA-256. Los archivos de configuración son idénticos. Odoo responde correctamente y permite iniciar sesión con la cuenta administradora.

El aislamiento mediante un PostgreSQL temporal, un Odoo temporal y una red Docker interna evita que la prueba interfiera con el servicio de producción.

El procedimiento automatizado tardó 46 segundos en un servidor ya preparado. Sin embargo, este tiempo no es el RTO real de un desastre completo.

La documentación quedará completamente cerrada cuando se repita la recuperación en una máquina virtual nueva, un cajero pueda acceder desde el TPV y se mida el tiempo total necesario para recuperar el servicio.
