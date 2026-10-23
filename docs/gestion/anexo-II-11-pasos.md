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
- **Red:** contratación de línea WAN, diseño de red segmentada y segura, y ampliación de la cobertura Wi-Fi mediante WDS.
- **Presencia web:** sitio informativo responsivo y accesible, alojado en AWS con dominio propio, HTTPS y despliegue como código.
- **Gestión:** ERP con TPV integrado y al menos un proceso de negocio automatizado de extremo a extremo.
- **Datos:** base de datos por establecimiento sobre almacenamiento redundante, con plan de copias verificado mediante restauración real.

Condiciones transversales: seguridad por defecto, reproducibilidad, documentación ejecutable por un técnico ajeno al proyecto y capacidad de cada miembro para defender el conjunto.

## 2. Requisitos

| Bloque | Requisitos funcionales | Requisitos no funcionales / criterios de aceptación |
|---|---|---|
| Hardware y presupuesto | Especificación de equipos de gerencia, TPV e impresoras; presupuesto con WAN y router adicional | Precios con fuente enlazada; justificación técnica de cada componente |
| Sistemas operativos | Dual boot funcional; TPV en modo restringido; impresora operativa | Cuentas separadas usuario/administrador, bloqueo de USB e instalación de software, firewall y actualizaciones activos; configuración scriptada |
| Arcade | Arranque directo a MAME; stick reconocido como dispositivo HID estándar con mapeo configurable | Mejora de rendimiento medida (FPS, CPU, RAM) antes y después; compatible con al menos dos emuladores |
| Redes | Esquema lógico y físico; direccionamiento y segmentación por función (TPV, gerencia, clientes, arcade); WDS | WPA2/WPA3, red de invitados aislada, administración no expuesta a Internet; cobertura y throughput medidos |
| Web | Geolocalización, formulario de contacto (placeholder) y slideshow de platos | HTML/CSS válidos, Lighthouse ≥ 90 en accesibilidad y rendimiento, HTTPS con dominio propio, despliegue por IaC |
| ERP + TPV | Facturación, CRM, empleados, marketing, inventario y TPV de restauración | Despliegue reproducible; flujo automatizado pedido → factura → envío → descuento de stock; importación/exportación de datos |
| Base de datos | Modelo E/R, lógico en 3FN y físico con datos y consultas | Usuarios con privilegios mínimos; scripts DDL versionados |
| Disponibilidad y copias | RAID 1 y plan de backup | Regla 3-2-1, copias cifradas y automatizadas; failover y restauración probados con evidencias |

## 3. Investigación

Fuentes y documentación técnica de referencia por bloque. Cada responsable añade lo que consulte.

| Bloque | Fuente |
|---|---|
| BD · Modelo E/R | Claude (ver [registro-ia.md](registro-ia.md)) |
| Arduino · Firmware HID y EEPROM | Claude; librería [mheironimus/ArduinoJoystickLibrary](https://github.com/MHeironimus/ArduinoJoystickLibrary) |
| Web · Hosting | Claude Code; [documentación de Certbot](https://eff-certbot.readthedocs.io), [DuckDNS](https://www.duckdns.org/spec.jsp), documentación de Amazon S3 y EC2 |
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
| Gestión de tareas | GitHub Projects + Gantt en el repo | Integrado con el repositorio; el Gantt se regenera desde el CSV | 21/10/2026 |
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
| 23/10/2026 | Seguridad | Contraseñas débiles de la VM del gerente en un fichero de texto sin seguimiento | No se sube (añadido al `.gitignore`); hay que cambiarlas y guardarlas en un gestor de contraseñas |

## 8. Pruebas

| Bloque | Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|---|
| SO | Arranque de ambos sistemas desde GRUB | Ambos arrancan y GRUB muestra las dos entradas | Pendiente de captura; las particiones y la EFI compartida sí están comprobadas | [tarea 12](../so/12-dual-boot.md) |
| SO | Cajero intenta instalar software / usar USB | Operación denegada | | |
| Arcade | Rendimiento MAME antes y después de optimizar | Aumento de FPS y menor consumo de RAM | Robby Roto +27 % y más estable, Gridlee +6 %, timers de 8 a 3, −277 MB de disco; la RAM no cambia. Medido en una VM de 2 núcleos y 1,5 GB: falta repetirlo con 1 núcleo y 1 GB | [tarea 17](../arcade/17-rendimiento-mame/DOCUMENTACION.md) |
| Arduino | Stick en MAME y en un segundo emulador | Todas las entradas reconocidas y remapeables | | |
| Redes | Cliente de la red de invitados accede a la red interna | Acceso bloqueado | Pendiente: la red de invitados aún no está configurada | [red segura](../redes/24-red-segura/DOCUMENTACION.md) |
| Redes | Roaming y throughput con WDS | Cobertura ampliada; velocidad medida con iperf3 | | |
| Web | Lighthouse y validador W3C | Sin errores; puntuación ≥ 90 | W3C sin errores; Lighthouse móvil 98/100/100/100 y escritorio 99/100/100/100 | [lighthouse-w3c.txt](../evidencias/web/lighthouse-w3c.txt) |
| Web | Acceso por HTTP | Redirección a HTTPS con certificado válido | `301` a HTTPS; certificado de Let's Encrypt válido hasta el 21/01/2027 | [tarea 30, sección 5](../web/30-hosting-aws.md#5-pruebas) |
| ERP | Venta en el TPV de barra | Ticket, cobro, cierre de caja y asiento contable | Mesa 3, 35,50 € en efectivo: factura simplificada, caja cuadrada (diferencia 0,00 €) y asiento `POSS/2026/10/0001` validado | [tarea 34, sección 8](../erp/34-configurar-odoo/DOCUMENTACION.md) |
| ERP | Factura automática de extremo a extremo | Pedido, factura validada, cobro y PDF sin intervención | Repetido el 23/10 en una instalación limpia: `INV/2026/00001` y `00002` cobradas y con PDF. No incluye envío por correo ni descuento de stock (ideas del plan, no exigidas por el enunciado) | [tarea 35](../erp/35-factura-automatica/DOCUMENTACION.md) |
| BD | Usuario de aplicación ejecuta DDL | Permiso denegado | `CREATE TABLE`: *permission denied for schema public*; `DROP` y `ALTER`: *must be owner*; `DELETE`/`UPDATE` de facturas denegados; 33 pruebas de reglas correctas (repetido el 23/10) | [verificación](verificacion.md), [05-pruebas.sql](../bd/scripts/05-pruebas.sql) |
| RAID | Retirada de un disco del RAID 1 | Servicio continúa; reconstrucción correcta | Los datos siguen accesibles y se puede escribir; arranca degradado; reconstrucción en 27 s con las sumas SHA-256 intactas | [tarea 43](../backup/43-raid1/DOCUMENTACION.md) |
| Backup | Restauración completa en entorno limpio | Datos íntegros; tiempo de recuperación registrado | Restaurada la copia del USB en un entorno aislado: 16 comprobaciones coinciden con producción; RTO 46 s | [tarea 45](../backup/45-restauracion/DOCUMENTACION.md) |

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
