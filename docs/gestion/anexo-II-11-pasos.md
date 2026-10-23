# Anexo II · Documento 11 pasos

| | |
|---|---|
| **Reto** | 1 · Almi-Chain |
| **Grupo** | ASIR1 2026-2027 |
| **Equipo** | Adrian, Iker, Eneko.S, Eneko.P (pendiente de confirmar si sigue), Markel, Peio |
| **Periodo** | 21/10/2026 – 10/11/2026 |
| **Responsable del documento** | Adrian |

---

## 1. Análisis del reto

Una cadena de restaurantes contrata el diseño e implantación de su infraestructura informática. El alcance es el siguiente:

- **Puestos de trabajo:** equipo de gerencia con arranque dual Windows 10 / GNU-Linux; dos TPV Windows de barra con impresoras de tickets, configurados con mínimos privilegios.
- **Ocio:** máquina recreativa MAME sobre hardware limitado (1 núcleo, 1 GB de RAM) y arcade stick propio basado en Arduino con HID nativo.
- **Red:** contratación de línea WAN, esquema de conectividad, plano de red con cableado y Wi-Fi, red configurada de forma segura y ampliación de la cobertura Wi-Fi mediante WDS. (La segmentación por grupos es una decisión del equipo, no del enunciado.)
- **Presencia web:** sitio informativo responsivo y accesible, alojado en AWS con dominio propio, HTTPS y despliegue reproducible, «a poder ser» automatizado con scripts o infraestructura como código.
- **Gestión:** ERP con TPV integrado y al menos un proceso de negocio automatizado de extremo a extremo.
- **Datos:** base de datos de los establecimientos (una base central con los datos de cada local, [tarea 38](../bd/38-modelo-er.md#11-una-base-central-para-toda-la-cadena)) sobre almacenamiento redundante, con plan de copias verificado mediante restauración real.

Condiciones transversales: seguridad por defecto, reproducibilidad, documentación ejecutable por un técnico ajeno al proyecto y capacidad de cada miembro para defender el conjunto.

## 2. Requisitos

La columna *Enunciado* recoge solo lo que dice el enunciado. Lo que añade el equipo (o venía en el plan de trabajo) va aparte: es opcional y, si no se hace, no se incumple el reto.

| Bloque | Lo pide el enunciado | Lo añade el equipo (criterios propios) |
|---|---|---|
| Hardware y presupuesto | Necesidades, configuración y presupuesto de equipos e impresoras; detalles del hardware y del software que se instala | Precios con fuente enlazada; justificación de cada componente; presupuesto con WAN, router adicional, servidor y copias |
| Sistemas operativos | Arranque dual Windows 10 - GNU/Linux para el gerente; 2 TPV Windows; restringidos al máximo, mínimos privilegios y seguridad por defecto; instalación y configuración de una impresora; documentación reproducible y diagrama que permita repetir la instalación | Cuentas separadas usuario/administrador, bloqueo de USB, firewall y actualizaciones activos; configuración con scripts |
| Arcade | MAME en un equipo de 1 núcleo y 1 GB, optimizado, con constancia de las pruebas de rendimiento; monitorización; arcade stick con Arduino compatible con cualquier emulador e input personalizable | Medidas de FPS, CPU y RAM antes y después; probar el stick con dos emuladores como muestra de «cualquier emulador» |
| Redes | Identificar necesidades de comunicación; contratar una línea WAN; esquema de conectividad; plano de red con cableado y Wi-Fi; red configurada de forma segura; segundo router por WDS comprobando que funciona | Segmentación por función (TPV, gerencia, clientes, arcade); WPA3; red de invitados aislada; medidas de cobertura y velocidad |
| Web | Unidireccional, atractiva, responsiva, accesible y con buen rendimiento; geolocalización, formulario de contacto (placeholder) y slideshow de platos; HTTPS, dominio propio, nube (AWS) y despliegue reproducible, a poder ser automatizado | HTML/CSS válidos en el W3C y Lighthouse ≥ 90 como forma de medir «accesible» y «buen rendimiento»; Terraform |
| ERP + TPV | ERP para facturas, clientes, personal, marketing, inventario…; al menos un caso de uso real de extremo a extremo automatizado (p. ej. emisión de una factura); importación, integración, aseguramiento y extracción de información (RA.7 de LMSGI) | Envío de la factura por correo y descuento de stock en el caso de uso (ideas del plan, no obligatorias) |
| Base de datos | Diseño del modelo E/R y tablas; implementación y consulta de sus datos | Normalización a 3FN, reglas con disparadores y usuarios con privilegios mínimos |
| Disponibilidad y copias | La BD en un dispositivo redundante; plan de copias de seguridad con prueba de restauración; verificar con pruebas (restauración, failover) | Regla 3-2-1, copias cifradas y automatizadas |
| Transversal | Seguridad por defecto (mínimos privilegios, gestión de credenciales y secretos, comunicaciones cifradas); documentación que un técnico nuevo pueda seguir, con diagramas; seguimiento con Gantt o Kanban y Git; documentación y presentación | KeePassXC para todas las contraseñas; gitleaks; revisión por Pull Request |

## 3. Investigación

Fuentes y documentación técnica de referencia por bloque. Cada responsable añade lo que consulte.

| Bloque | Fuente |
|---|---|
| BD · Modelo E/R | Apuntes de clase de Gestión de Bases de Datos (modelo E/R, paso a tablas y normalización); [documentación de PostgreSQL](https://www.postgresql.org/docs/) (restricciones, disparadores y roles). El uso de IA está en el [registro de IA](registro-ia.md) |
| Arduino · Firmware HID y EEPROM | [Documentación de Arduino Leonardo](https://docs.arduino.cc/hardware/leonardo/) (HID nativo del ATmega32U4), [referencia de EEPROM de Arduino](https://docs.arduino.cc/learn/built-in-libraries/eeprom/) y la librería [mheironimus/ArduinoJoystickLibrary](https://github.com/MHeironimus/ArduinoJoystickLibrary). El uso de IA está en el registro de IA |
| Web · Hosting | [Documentación de Certbot](https://eff-certbot.readthedocs.io), [DuckDNS](https://www.duckdns.org/spec.jsp), documentación de Amazon S3 y EC2 |
| Web · Validación | [Lighthouse](https://developer.chrome.com/docs/lighthouse), [validador Nu del W3C](https://validator.w3.org/nu/) |
| ERP · Comparativa | Fuentes de Odoo, Dolibarr y ERPNext consultadas el 22/10 ([tarea 32](../erp/32-comparativa-erp.md)) |
| ERP · Odoo | Documentación de Odoo 19 y su API XML-RPC ([tareas 33-35](../erp/)) |
| Copias · restic y mdadm | Documentación de restic y de mdadm ([tareas 43-45](../backup/)) |
| Arcade · MAME y Batocera | Documentación de MAME, Debian (preseed) y Batocera ([tareas 16-18](../arcade/)) |

## 4. Alternativas evaluadas

| Decisión | Opciones | Criterios |
|---|---|---|
| ERP | Odoo Community, Dolibarr, ERPNext | Módulos requeridos, TPV de restauración, coste de licencia, API |
| Hosting web | S3 + CloudFront + ACM, S3 + EC2 con nginx | Coste, mantenimiento, HTTPS gestionado, dominio gratuito |
| IaC | Terraform, CloudFormation | Portabilidad, curva de aprendizaje |
| SO de la recreativa | Debian mínimo, Alpine, Lakka | Consumo de RAM, soporte de MAME, mantenimiento |
| Firmware de router | OpenWrt, DD-WRT | Soporte WDS, compatibilidad del hardware |
| SGBD | MariaDB, PostgreSQL | Herramientas de la asignatura, integración con Odoo |
| Backup | restic, borg, rsync + cron | Cifrado, deduplicación, destino S3 |
| Placa del arcade stick | Arduino Leonardo, Pro Micro | HID nativo, precio, tamaño |

## 5. Decisiones

| Decisión | Elección | Justificación | Fecha |
|---|---|---|---|
| Gestión de tareas | Gantt en el repo, generado desde el CSV | El enunciado pide Gantt o Kanban. El Gantt vive en el repositorio y se regenera con un script; el tablero de GitHub Projects se creó pero no se usa | 21/10/2026 (revisado el 23/10) |
| Firmware del arcade stick | Joystick HID estándar (no teclado) | Cualquier emulador lo reconoce como mando sin drivers, no interfiere con el teclado y el mapeo se personaliza en la EEPROM; todo el firmware está hecho así. Moneda y Start se asignan una vez en MAME ([STICK-ARDUINO.md](../arcade/16-recreativa-mame/STICK-ARDUINO.md)) | 23/10/2026 |
| Línea WAN | Fibra DIGI 1 Gb, 30 €/mes | Es la que elige la comparativa ([tarea 22](../redes/22-comparativa-wan.md)) y la que ya usaba el plano (tarea 23); el presupuesto se corrige para que coincida (360 €/año en vez de 588,12 €) | 23/10/2026 |
| Contraseñas | Robustas, generadas y guardadas en KeePassXC; nunca en texto plano ni en Git | Lo exigen el enunciado (gestión de credenciales y secretos) y el plan | 23/10/2026 |
| Reparto tras la revisión del estado | Software pendiente para Adrian e Iker; tareas físicas para cualquiera salvo Eneko.P; las tareas con parte en VM y parte física se separan | Eneko.P está pendiente de confirmar si sigue; Adrian e Iker son quienes han hecho casi todo el software ([roles.md](roles.md), [verificacion.md](verificacion.md)) | 23/10/2026 |
| ERP | Odoo Community | Cubre las funciones del enunciado con un TPV táctil integrado, usa PostgreSQL, tiene más documentación en español y es gratuito ([tarea 32](../erp/32-comparativa-erp.md), sección 6) | 22/10/2026 |
| Hosting web | Bucket S3 privado + EC2 con nginx, IP elástica, dominio `almichain1.duckdns.org` y certificado de Let's Encrypt | Dominio y certificado gratuitos. DuckDNS solo admite registros A, y CloudFront y ACM necesitan CNAME; con una IP elástica basta un registro A ([tarea 30](../web/30-hosting-aws.md)) | 23/10/2026 |
| IaC | | | |
| SO de la recreativa | *Provisional:* Debian 13 mínimo con arranque directo a MAME | Arranca a MAME en 4,7 s sin escritorio ([tarea 16](../arcade/16-recreativa-mame/DOCUMENTACION.md)). Se está probando Batocera para compararlas con datos en una VM de 1 núcleo y 1 GB ([notas](../arcade/16-batocera/NOTAS.md)) | 23/10/2026 |
| Firmware de router | | | |
| SGBD | PostgreSQL | Lo exige Odoo, así que todo el proyecto usa un único gestor. Scripts DDL probados en PostgreSQL 16 ([tarea 40](../bd/40-scripts-ddl.md)); Odoo corre sobre PostgreSQL 17 ([tarea 33](../erp/33-odoo-docker/DOCUMENTACION.md)) | 22/10/2026 |
| Backup | restic sobre RAID 1 (`mdadm`) y disco USB externo | Copias cifradas con AES-256, deduplicadas y automatizadas; cumple la regla 3-2-1 ([tarea 44](../backup/44-backup-3-2-1/DOCUMENTACION.md)) | 22/10/2026 |
| Placa del arcade stick | Arduino Leonardo (ATmega32U4) | HID nativo por USB sin drivers; compatible con la librería Joystick; EEPROM para guardar el mapeo | 22/10/2026 |

## 6. Planificación

- Diagrama de Gantt y carga por persona: [gantt.md](gantt.md).
- Fuente de datos de la planificación: [backlog-kanban.csv](backlog-kanban.csv).
- Criterios de reparto y revisión: [roles.md](roles.md).

| Semana | Fechas | Objetivo |
|---|---|---|
| 1 | 21/10 – 27/10 | Organización, requisitos, comparativas, diseño (red, web, E/R) y presupuesto |
| 2 | 28/10 – 03/11 | Implantación: SO y TPV, recreativa y stick, red y WDS, web, Odoo, BD y RAID |
| 3 | 04/11 – 10/11 | AWS e IaC, caso de uso del ERP, backups y restauración, pruebas, documentación y defensa |

> **Fechas del reto:** del lunes 26/10 al jueves 12/11/2026. La planificación actual vale y se revisará cuando salga la rúbrica (decisión del 24/10/2026). Las tareas ya hechas conservan sus fechas reales.

## 7. Ejecución

| Bloque | Ubicación en el repositorio |
|---|---|
| Documentación y diagramas | `docs/`, `docs/diagramas/` |
| Scripts de configuración y backup | `scripts/` |
| Infraestructura AWS | `iac/` |
| Web | `web/` |
| Arcade stick | `arduino/` |
| Evidencias | `docs/evidencias/` |

Incidencias relevantes durante la ejecución:

| Fecha | Bloque | Incidencia | Resolución |
|---|---|---|---|
| 22/10/2026 | Arcade | Debian 13 reserva el nombre de usuario `admin` y el instalador desatendido se paraba | El administrador se llama `tecnico` ([tarea 16](../arcade/16-recreativa-mame/DOCUMENTACION.md)) |
| 22/10/2026 | Arcade | Las medidas de rendimiento se hicieron en una VM de 2 núcleos y 1,5 GB, no de 1 núcleo y 1 GB como pide el enunciado | Hay que repetirlas en la VM `Recreativa-1GB` ([tarea 17](../arcade/17-rendimiento-mame/DOCUMENTACION.md)) |
| 22/10/2026 | ERP | Odoo se instaló antes de cerrar la comparativa de ERP (tarea 32) | La tarea 32 eligió Odoo Community, así que no hay que rehacer nada |
| 22/10/2026 | ERP | Crear la factura por XML-RPC devolvía `cannot marshal None` | La acción sí se ejecuta; el script lo controla ([tarea 35](../erp/35-factura-automatica/DOCUMENTACION.md)) |
| 22/10/2026 | Redes | El router TP-Link TL-WR841N v14 no admite WPA3 | Se usa WPA2-PSK con AES; para WPA3 hace falta otro equipo ([red segura](../redes/24-red-segura/DOCUMENTACION.md)) |
| 23/10/2026 | Web | Sin presupuesto para un dominio de pago; DuckDNS (gratuito) no admite CNAME, así que no puede apuntar a CloudFront ni validar un certificado de ACM | Se cambia a EC2 con IP elástica y Let's Encrypt; S3 sigue guardando la web ([tarea 30](../web/30-hosting-aws.md), sección 2) |
| 23/10/2026 | Web | La consola de AWS no admite nombres de grupo de seguridad que empiecen por `sg-` | Se llama `web-almichain-sg` |
| 23/10/2026 | Web | La redirección de HTTP que crea certbot mostraba la versión de nginx | `server_tokens off` en el bloque `http` del script |
| 23/10/2026 | Web | Lighthouse: contraste insuficiente en tres textos, imágenes de 1600 px en móvil y un error del W3C | Corregido en `web/` (PR #25); Lighthouse 98-100 |
| 23/10/2026 | ERP | En una instalación limpia de Odoo, `configurar-odoo.py` y `cargar-carta-y-mesas.py` fallaban (almacén buscado antes de instalar Inventario; `copy` devuelve una lista en Odoo 19) | Corregidos y repetida toda la instalación hasta la factura ([verificación](verificacion.md), sección 4) |
| 23/10/2026 | Gestión | 14 enlaces rotos y documentos fuera de la carpeta de su bloque | Movidos a `docs/redes/` y `docs/bd/` y enlaces corregidos; `scripts/verificar-repo.sh` lo comprueba |
| 23/10/2026 | Seguridad | Contraseñas débiles de la VM del gerente en un fichero de texto sin seguimiento | No se sube (añadido al `.gitignore`); se cambian y se guardan en KeePassXC (tarea 55) |

## 8. Pruebas

| Bloque | Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|---|
| SO | Arranque de ambos sistemas desde GRUB | Ambos arrancan y GRUB muestra las dos entradas | GRUB 2.14 muestra Ubuntu y Windows Boot Manager; particiones, EFI compartida, cuentas, firewall y Windows Update comprobados; contraseñas robustas en KeePassXC (23/10) | [tarea 12](../so/12-dual-boot.md) |
| SO | Cajero intenta instalar software / usar USB | Operación denegada | | |
| Arcade | Rendimiento MAME antes y después de optimizar | Aumento de FPS y menor consumo de RAM | Robby Roto +27 % y más estable, Gridlee +6 %, timers de 8 a 3, −277 MB de disco; la RAM no cambia. Medido en una VM de 2 núcleos y 1,5 GB: falta repetirlo con 1 núcleo y 1 GB | [tarea 17](../arcade/17-rendimiento-mame/DOCUMENTACION.md) |
| Arduino | Stick en MAME y en un segundo emulador | Todas las entradas reconocidas y remapeables | | |
| Redes | Cliente de la red de invitados accede a la red interna | Acceso bloqueado | Pendiente: la red de invitados aún no está configurada | [red segura](../redes/24-red-segura/DOCUMENTACION.md) |
| Redes | Roaming y throughput con WDS | Cobertura ampliada; velocidad medida con iperf3 | | |
| Web | Lighthouse y validador W3C | Sin errores; puntuación ≥ 90 | W3C sin errores; Lighthouse móvil 98/100/100/100 y escritorio 99/100/100/100 | [lighthouse-w3c.txt](../evidencias/web/lighthouse-w3c.txt) |
| Web | Acceso por HTTP | Redirección a HTTPS con certificado válido | `301` a HTTPS; certificado de Let's Encrypt válido hasta el 21/01/2027 | [tarea 30, sección 5](../web/30-hosting-aws.md#5-pruebas) |
| ERP | Venta en el TPV de barra | Ticket, cobro, cierre de caja y asiento contable | Mesa 3, 35,50 € en efectivo: factura simplificada, caja cuadrada (diferencia 0,00 €) y asiento `POSS/2026/10/0001` validado | [tarea 34, sección 8](../erp/34-configurar-odoo/DOCUMENTACION.md) |
| ERP | Factura automática de extremo a extremo | Pedido, factura validada, cobro y PDF sin intervención | Repetido el 23/10 en una instalación limpia: `INV/2026/00001` y `00002` cobradas y con PDF. No incluye envío por correo ni descuento de stock (ideas del plan, no exigidas por el enunciado). El 24/10 el caso de uso pasa a un menú de grupo con IVA del 10 %: hay que repetirlo | [tarea 35](../erp/35-factura-automatica/DOCUMENTACION.md) |
| BD | Usuario de aplicación ejecuta DDL | Permiso denegado | `CREATE TABLE`: *permission denied for schema public*; `DROP` y `ALTER`: *must be owner*; `DELETE`/`UPDATE` de facturas denegados; 33 pruebas de reglas correctas (repetido el 23/10) | [verificación](verificacion.md), [05-pruebas.sql](../bd/scripts/05-pruebas.sql) |
| RAID | Retirada de un disco del RAID 1 | Servicio continúa; reconstrucción correcta | Los datos siguen accesibles y se puede escribir; arranca degradado; reconstrucción en 27 s con las sumas SHA-256 intactas. **Falta:** la BD viva aún no está en el RAID ([tarea 43, sección 7](../backup/43-raid1/DOCUMENTACION.md#7-pendiente-la-base-de-datos-tiene-que-estar-en-el-raid)) | [tarea 43](../backup/43-raid1/DOCUMENTACION.md) |
| Backup | Restauración completa en entorno limpio | Datos íntegros; tiempo de recuperación registrado | Restaurada la copia del USB en un entorno aislado: 16 comprobaciones coinciden con producción; 46 s de restauración en el mismo servidor. **Falta** el RTO real, restaurando en una máquina nueva | [tarea 45](../backup/45-restauracion/DOCUMENTACION.md) |

## 9. Documentación y presentación

| Entregable | Responsable | Estado |
|---|---|---|
| Documentación técnica paso a paso | Markel | Pendiente (base: [LOGICA_RETO.md](../../LOGICA_RETO.md)) |
| Diagramas (sistemas, red, AWS, BD) | Responsable de cada bloque | Pendiente |
| Tabla de pruebas | Eneko.S | Pendiente (base: [verificacion.md](verificacion.md)) |
| Presentación y ensayo | Peio | Pendiente |

## 10. Evaluación y retrospectiva

| | |
|---|---|
| **Qué ha funcionado** | |
| **Qué mejorar** | |
| **Desviaciones respecto a la planificación** | |
| **Uso de IA y validación** | Ver [registro-ia.md](registro-ia.md) |
