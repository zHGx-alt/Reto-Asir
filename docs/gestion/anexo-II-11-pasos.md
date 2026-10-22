# Anexo II · Documento 11 pasos

| | |
|---|---|
| **Reto** | 1 · Almi-Chain |
| **Grupo** | ASIR1 2026-2027 |
| **Equipo** | Adrian, Iker, Eneko.S, Eneko.P, Markel, Peio |
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

## 4. Alternativas evaluadas

| Decisión | Opciones | Criterios |
|---|---|---|
| ERP | Odoo Community, Dolibarr, ERPNext | Módulos requeridos, TPV de restauración, coste de licencia, API |
| Hosting web | S3 + CloudFront, EC2 | Coste, mantenimiento, HTTPS gestionado |
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
| ERP | | | |
| Hosting web | | | |
| IaC | | | |
| SO de la recreativa | | | |
| Firmware de router | | | |
| SGBD | | | |
| Backup | | | |
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
| | | | |

## 8. Pruebas

| Bloque | Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|---|
| SO | Arranque de ambos sistemas desde GRUB | Ambos arrancan y GRUB muestra las dos entradas | | |
| SO | Cajero intenta instalar software / usar USB | Operación denegada | | |
| Arcade | Rendimiento MAME antes y después de optimizar | Aumento de FPS y menor consumo de RAM | | |
| Arduino | Stick en MAME y en un segundo emulador | Todas las entradas reconocidas y remapeables | | |
| Redes | Cliente de la red de invitados accede a la red interna | Acceso bloqueado | | |
| Redes | Roaming y throughput con WDS | Cobertura ampliada; velocidad medida con iperf3 | | |
| Web | Lighthouse y validador W3C | Sin errores; puntuación ≥ 90 | | |
| Web | Acceso por HTTP | Redirección a HTTPS con certificado válido | | |
| ERP | Pedido en TPV | Factura emitida, enviada por correo y stock descontado | | |
| BD | Usuario de aplicación ejecuta DDL | Permiso denegado | | |
| RAID | Retirada de un disco del RAID 1 | Servicio continúa; reconstrucción correcta | | |
| Backup | Restauración completa en entorno limpio | Datos íntegros; tiempo de recuperación registrado | | |

## 9. Documentación y presentación

| Entregable | Responsable | Estado |
|---|---|---|
| Documentación técnica paso a paso | Markel | Pendiente |
| Diagramas (sistemas, red, AWS, BD) | Responsable de cada bloque | Pendiente |
| Tabla de pruebas | Eneko.P | Pendiente |
| Presentación y ensayo | Peio | Pendiente |

## 10. Evaluación y retrospectiva

| | |
|---|---|
| **Qué ha funcionado** | |
| **Qué mejorar** | |
| **Desviaciones respecto a la planificación** | |
| **Uso de IA y validación** | Ver [registro-ia.md](registro-ia.md) |
