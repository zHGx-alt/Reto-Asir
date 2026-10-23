# Verificación del estado del reto (23/10/2026)

Revisión de todo el repositorio contra el enunciado ([Reto_1_ASIR1_2026-2027.docx](../../Reto_1_ASIR1_2026-2027.docx)) y el plan ([almi-chain-plan.pdf](../../almi-chain-plan.pdf)). Para cada tarea se ha leído su documento y, donde se podía, se ha **vuelto a ejecutar** lo que dice que funciona. El estado resultante está en el [Gantt](gantt.md) (secciones *Tareas hechas* y *Tareas sin terminar*).

Hecho por Adrian con Claude Code ([registro de IA](registro-ia.md)).

## 1. Criterio

| Estado | Significa |
|---|---|
| **Hecho** | El entregable existe, tiene evidencias y, si se podía, se ha comprobado de nuevo. Puede faltar la revisión del compañero. |
| **En curso** | Hay una parte hecha y una lista concreta de lo que falta (columna *Qué falta* del Gantt). |
| **Pendiente** | No hay nada entregado. |

| Tipo | Significa |
|---|---|
| **Software** | Se hace en un ordenador o en una máquina virtual. |
| **Físico** | Necesita el equipo real: montar, cablear o configurar hardware. |
| **Documentación / Gestión** | Documentos de diseño, comparativas, anexos y planificación. |

## 2. Pruebas que se pueden repetir con un comando

```bash
bash scripts/verificar-repo.sh
```

Las que necesitan Docker o PlatformIO se saltan si no están instalados. Resultado del 23/10/2026: **todo correcto**.

| # | Qué se comprueba | Cómo | Resultado |
|---|---|---|---|
| 1 | El backlog es coherente (dependencias, fechas, tipos, evidencias que existen, nadie se revisa a sí mismo) | `python3 scripts/gantt.py` | ✅ |
| 2 | Ningún enlace relativo roto en los `.md` | Script de enlaces | ✅ 0 rotos (antes: 14, ver sección 4) |
| 3 | Sintaxis de los scripts de Python y de shell | `py_compile` y `bash -n` | ✅ |
| 4 | Errores de shellcheck | `koalaman/shellcheck:v0.10.0` | ✅ 0 errores. Un único aviso menor (variable `i` sin usar en `medir-batocera.sh`) |
| 5 | Firmware del arcade stick (tarea 20) | `pio run` | ✅ Compila. Flash 37,3 %, RAM 17,4 % |
| 6 | Scripts DDL (tarea 40) | PostgreSQL 16 en Docker | ✅ 01, 02 y 03 sin errores; 03 repetible; `05-pruebas.sql` 33/33 dos veces seguidas y la tabla `factura` vacía al acabar; 04 borra y se puede recrear |
| 7 | Mínimos privilegios en la BD (tarea 42) | Usuario con `rol_aplicacion` | ✅ `CREATE TABLE` → *permission denied for schema public*; `DROP` y `ALTER` → *must be owner*; `DELETE` y `UPDATE` de facturas → *permission denied*; `SELECT` permitido |
| 8 | Web válida (tarea 29) | Validador Nu del W3C en Docker | ✅ 0 errores en `index.html` y en `style.css` |
| 9 | Secretos en todo el historial | gitleaks 8.18.4 con `.gitleaks.toml` | ✅ 81 commits, sin fugas |

## 3. Pruebas hechas a mano el 23/10/2026

| # | Tarea | Qué se hizo | Resultado |
|---|---|---|---|
| 1 | 33 | Despliegue de Odoo con el mismo `docker-compose.yml` en un Docker limpio (réplica de `desplegar-odoo.sh` sin root) | ✅ `/web/login` 200; gestor de bases de datos desactivado; PostgreSQL sin puerto publicado; `admin/admin` rechazado |
| 2 | 34 | `configurar-odoo.py` en la base recién creada | ❌ → ✅ Fallaba en una base nueva (ver 4.1). Corregido: instala los 8 módulos, plan contable PYMES, 2 TPV de restaurante y los usuarios. Segunda ejecución sin cambios (idempotente) |
| 3 | 34 | `cargar-carta-y-mesas.py` | ❌ → ✅ Fallaba al crear la carta (ver 4.2). Corregido: 15 productos con IVA 10 % incluido, salas y mesas. Repetido dos veces |
| 4 | 35 | `factura_automatica.py` dos veces, como `gerente` | ✅ `INV/2026/00001` (12,10 €) e `INV/2026/00002` (193,60 €) validadas, cobradas y con PDF |
| 5 | 34 | `cajero1` intenta cambiar un precio y crear un usuario | ✅ Las dos operaciones, denegadas |
| 6 | 12 | SHA-256 de los ficheros de la VM del repositorio contra el `.mf` y el documento | ✅ Coinciden `.ovf` y `.nvram`. Tras cambiar las contraseñas (tarea 55) la VM se exportó de nuevo el mismo día y las sumas nuevas, `.vmdk` incluido, están en la tarea 12 |
| 7 | 8, 10 | Sumas del presupuesto | ✅ 2.361,36 € (tarea 8); 2.447,34 € de inversión (tarea 10). El primer año pasa de 3.035,46 € a 2.807,34 € al cambiar la WAN a DIGI (ver sección 6) |
| 8 | 30 | `nginx -t` de la configuración que genera `instalar-servidor-web.sh` | ✅ Sintaxis correcta |
| 9 | 30 | `curl` a `https://almichain1.duckdns.org` | ⏸ Sin respuesta: el DNS apunta a la IP elástica `52.200.94.167`, pero el Learner Lab está parado. Es lo esperado (sección 8 de la tarea 30); las pruebas con el laboratorio encendido están en sus evidencias |
| 10 | 5 | Autores de los commits de `main` | 5 de 6 personas tienen commits propios; Eneko.P no tiene ninguno |
| 11 | 5 | CI de gitleaks en GitHub | ✅ Los 3 últimos merges a `main`, en verde |
| 12 | 4 | Tablero de GitHub Projects | Existe, pero no se usa (confirmado por el equipo): el seguimiento es el Gantt |

La salida de las pruebas 1-5 está en [prueba-instalacion-limpia.txt](../erp/34-configurar-odoo/evidencias/prueba-instalacion-limpia.txt) (sin contraseñas).

**No se ha podido comprobar desde aquí** (hace falta la VM o el equipo de cada uno): el arranque dual, la recreativa, el RAID, las copias y la restauración, y la red física. Para esas tareas se ha comprobado que el documento, los scripts y las evidencias son coherentes entre sí y con lo que pide el enunciado.

## 4. Problemas encontrados y corregidos

### 4.1 `configurar-odoo.py` no funcionaba en una base nueva

Al renombrar el almacén (cambio del 23/10) se buscaba `stock.warehouse` **antes** de instalar Inventario. En la VM de Iker funcionaba porque Inventario ya estaba instalado; en una instalación nueva fallaba con `Object stock.warehouse doesn't exist`. El renombrado se ha movido después de instalar los módulos.

### 4.2 `cargar-carta-y-mesas.py` no funcionaba en una base nueva

En Odoo 19, `copy` devuelve por la API una **lista** de ids. El script la metía dentro de otra lista (`[[id]]`) al crear el IVA 10 % incluido, y crear el primer producto fallaba con `unhashable type: 'list'`. En la VM de Iker no se veía porque el impuesto ya existía. Ahora se acepta un id o una lista.

### 4.3 Enlaces rotos

- Las 11 imágenes de la red segura (tarea 24) apuntaban a `imagenes/`, que no existía. Ahora el documento está en `docs/redes/24-red-segura/` y las imágenes en su carpeta `imagenes/`.
- Tres enlaces de la recreativa apuntaban a `../arcade-stick/`, que no existe. Ahora apuntan a `arduino/mando-joystick/`.

### 4.4 Ficheros movidos a la carpeta de su bloque

| Antes | Ahora |
|---|---|
| `docs/gestion/tarea-22.md` | `docs/redes/22-comparativa-wan.md` |
| `docs/evidencias/Configurar-red-segura/` | `docs/redes/24-red-segura/` |
| `docs/diagramas/modelo-er.md` | `docs/bd/38-modelo-er.md` |
| `docs/diagramas/39-modelo-logico-3fn.md` | `docs/bd/39-modelo-logico-3fn.md` |
| `docs/bd/scripts/40-scripts-ddl.md` | `docs/bd/40-scripts-ddl.md` (los `.sql` siguen en `docs/bd/scripts/`) |

### 4.5 Contraseñas fuera de Git

En la carpeta de trabajo de Adrian había un fichero sin seguimiento, `VM dual boot.txt`, con las contraseñas de la VM del gerente, que además son muy débiles. No se ha subido; se ha añadido al `.gitignore` junto con `CREDENCIALES*` y `.credenciales*`. **Hecho el 23/10 (tarea 55):** las contraseñas se han cambiado por otras robustas, guardadas en KeePassXC. Falta borrar el `.txt`. El enunciado lo exige («soluciones seguras», «gestión de credenciales y secretos») y el plan dice «sin contraseñas por defecto ni en texto plano».

## 5. Estados corregidos en el backlog

| # | Tarea | Antes | Ahora | Por qué |
|---|---|---|---|---|
| 12 | Dual boot | Hecho | En curso → Hecho | Tenía 3 pruebas *Pendiente de captura*; se completaron el mismo 23/10 (GRUB, cuentas, firewall e historial de Windows Update) |
| 16 | Recreativa en VM | En curso | Hecho | Hecha y probada en VM; lo físico pasa a la tarea 53 y Batocera a la 51 |
| 23 | Plano y direccionamiento | Pendiente | Hecho | Están el plano, el plan de IP, la segmentación y la simulación en Packet Tracer |
| 24 | Red segura | Hecho | En curso | Su propio documento dice que faltan la red de invitados y WPA3 |
| 29 | W3C y Lighthouse | Pendiente | Hecho | Evidencias del 23/10 y W3C repetido |
| 42 | Usuarios de BD | Pendiente | En curso | Los roles existen y funcionan; faltan los usuarios con login |

## 6. Incoherencias entre documentos (sin corregir: las decide el responsable)

| Dónde | Problema |
|---|---|
| Tarea 35 | El Anexo II la daba como *parcial*. El enunciado pide *al menos un caso de uso* y la factura lo es; el envío por correo y el descuento de stock eran ejemplos del plan |
| Tarea 9 | No indica la versión de cada programa |
| Tareas 7 y 8 | Los equipos traen Windows 11 Pro y el enunciado exige Windows 10: falta confirmar los derechos de *downgrade* (incidencia H-01) |

Resueltas después de la revisión (23/10): **la WAN es DIGI 1 Gb** en todos los documentos (la comparativa ya lo elegía y el plano lo usaba; el presupuesto pasa de Telefónica 600 Mb, 588,12 €/año, a DIGI, 360 €/año); el diagrama de la tarea 11 se ha actualizado (EC2, recreativa en la Wi-Fi de invitados, modelos y SVG regenerado) y la documentación del stick deja el **joystick HID**, que es como está hecho el firmware.

## 7. Lo que pide el enunciado y no tiene tarea terminada

| Requisito del enunciado | Tarea | Estado |
|---|---|---|
| TPV restringidos con mínimos privilegios | 13, 15 | Pendiente |
| Instalación y configuración de una impresora | 14, 37 | Pendiente |
| Arcade stick montado y probado con dos emuladores | 19, 50, 21 | Pendiente |
| Recreativa de 1 núcleo y 1 GB con pruebas de rendimiento | 17, 18, 51, 53, 54 | En curso / pendiente |
| Red segura con WDS comprobado | 24, 25, 26 | En curso / pendiente |
| Despliegue reproducible automatizado (IaC) | 31 | Pendiente (el enunciado lo pide «a poder ser») |
| ERP: importación y extracción de datos (RA.7 de LMSGI) | 36 | Pendiente |
| BD: implementación **y consulta de sus datos** | 41 | Pendiente |
| Comunicaciones cifradas en toda la solución | 52, 46 | Pendiente (Odoo va por HTTP) |
| Tabla de pruebas, documentación y presentación | 47, 48, 49 | Pendiente |
