# Planificación · Diagrama de Gantt

Del 21/10/2026 al 10/11/2026 (15 días laborables).

> Fichero generado con `python3 scripts/gantt.py` a partir de [backlog-kanban.csv](backlog-kanban.csv). Para cambiar fechas o responsables, edita el CSV y vuelve a generarlo.

![Diagrama de Gantt](gantt.svg)

Cada barra tiene el color de su responsable. La columna *Necesita* indica qué tareas tienen que estar terminadas antes de empezar.

## Resumen

**23 de 54 tareas hechas (42 %).** *Hecho* significa que el entregable existe y tiene evidencias; las comprobaciones del 23/10/2026 están en [verificacion.md](verificacion.md).

| Tipo | Hechas | En curso | Pendientes | Total |
|---|---|---|---|---|
| Gestión | 2 | 2 | 2 | 6 |
| Documentación | 10 | 1 | 3 | 14 |
| Software | 11 | 6 | 8 | 25 |
| Físico | 0 | 1 | 8 | 9 |

*Software* se hace en un ordenador o en una máquina virtual; *Físico* necesita el equipo real (montar, cablear o configurar hardware).

## Tareas sin terminar

Ordenadas por estado y fecha de fin. *Qué falta* sale de revisar el documento de cada tarea.

| # | Tarea | Tipo | Responsable | Fin | Estado | Qué falta | Evidencia |
|---|---|---|---|---|---|---|---|
| 5 | Repo con estructura y gitleaks; commits de todos | Gestión | Adrian | 22/10 | En curso | Estructura, .gitignore y gitleaks hechos: CI en verde y gitleaks local sin fugas en 81 commits (23/10). Tienen commits 5 de 6 personas; falta Eneko.P (Anexo IX). | [gitleaks.yml](../../.github/workflows/gitleaks.yml) |
| 11 | Diagrama de arquitectura de equipos | Documentación | Iker | 28/10 | En curso | Borrador desactualizado: dibuja CloudFront (se usa EC2 con nginx); pone la recreativa por cable (va por la Wi-Fi de invitados) y le faltan los modelos de las tareas 8 y 9. | [DIAGRAMA.md](../../docs/diagramas/11-arquitectura-equipos/DIAGRAMA.md) |
| 51 | Comparar Batocera con Debian en VM de 1 núcleo y 1 GB y decidir el SO | Software | Iker | 28/10 | En curso | Batocera arranca con 1 GB (565 MB usados solo con el menú). Faltan medidas; endurecimiento (root con contraseña por defecto) y la decisión en el Anexo II. | [NOTAS.md](../../docs/arcade/16-batocera/NOTAS.md) |
| 12 | Dual boot Win10 + Linux en el equipo del gerente (VM) | Software | Adrian | 30/10 | En curso | Hecho en VMware y entregado (SHA-256 del .ovf y la .nvram comprobados el 23/10). Faltan 3 capturas: menú de GRUB; net localgroup Administradores; firewall y Windows Update. Pasa de Eneko.P a Adrian, que hizo la VM. | [12-dual-boot.md](../../docs/so/12-dual-boot.md) |
| 17 | Pruebas de rendimiento MAME antes/después (VM de 1 núcleo y 1 GB) | Software | Iker | 30/10 | En curso | Antes y después hechos en una VM de 2 núcleos y 1,5 GB. En la VM de 1 núcleo y 1 GB (la que pide el enunciado) solo hay 3 medidas de antes; faltan las de después. | [DOCUMENTACION.md](../../docs/arcade/17-rendimiento-mame/DOCUMENTACION.md) |
| 24 | Configurar red segura (WPA3; invitados; firewall) | Físico | Peio | 30/10 | En curso | Hecho en un TL-WR841N: administración remota cerrada; WPA2-AES; SPI y anti-DoS. Faltan la red de invitados aislada con su prueba y WPA3 (el TL-WR841N no lo admite; hace falta el Archer C6). Estaba en Hecho; su propio documento dice que no está terminada. | [DOCUMENTACION.md](../../docs/redes/24-red-segura/DOCUMENTACION.md) |
| 18 | Monitorización de recursos de la recreativa | Software | Adrian | 02/11 | En curso | Scripts hechos y probados en Linux. Falta ejecutarlos en la VM de 1 GB y guardar los CSV. Pasa de Eneko.S a Adrian. | [18-monitorizacion-recreativa.md](../../docs/arcade/18-monitorizacion-recreativa.md) |
| 42 | Usuarios de BD con mínimos privilegios | Software | Adrian | 03/11 | En curso | Roles de grupo hechos. Probado el 23/10: un usuario con rol_aplicacion no puede CREATE; DROP; ALTER ni borrar facturas. Faltan los usuarios con LOGIN documentados y la evidencia. Pasa de Markel a Adrian. | [03-roles.sql](../../docs/bd/scripts/03-roles.sql) |
| 44 | Plan de backup 3-2-1 cifrado y automatizado | Software | Iker | 04/11 | En curso | Funciona para Odoo: cifrado; diario; RAID y USB. Falta añadir la BD de la tarea 41. Pasa de Markel a Iker, que la hizo. | [DOCUMENTACION.md](../../docs/backup/44-backup-3-2-1/DOCUMENTACION.md) |
| 2 | Mantener Anexo II (11 pasos) | Gestión | Adrian | 10/11 | En curso | Dura todo el reto. Faltan las secciones 9 (entrega) y 10 (retrospectiva). | [anexo-II-11-pasos.md](../../docs/gestion/anexo-II-11-pasos.md) |
| 4 | Crear tablero Kanban en GitHub Projects | Gestión | Iker | 27/10 | Pendiente | No se ha podido comprobar si existe (el token de gh no tiene permiso read:project). El enunciado pide Gantt o Kanban: ya se cumple con el Gantt. | — |
| 6 | Resolver dudas pendientes con el profesor | Gestión | Peio | 27/10 | Pendiente | Sin acta. Dudas abiertas: dual boot en VM; TicketBAI o Veri*Factu; número de impresoras (S-01 de la tarea 7); Anexos VI a IX. | — |
| 19 | Montaje del arcade stick (ATmega32U4) | Físico | Markel | 27/10 | Pendiente | Esquema de conexiones hecho; falta cablear la placa y conseguir la palanca. Pasa de Eneko.P a Markel. | [esquema-conexiones.svg](../../arduino/mando-joystick/esquema-conexiones.svg) |
| 14 | Driver y cola de la impresora de tickets en el TPV (VM) y prueba | Software | Adrian | 30/10 | Pendiente | Sin empezar. Imprimir en la impresora real es la tarea 37. Pasa de Peio a Adrian. | — |
| 50 | Probar el firmware del stick en la placa (HID; comandos; EEPROM) | Físico | Adrian | 30/10 | Pendiente | Lista de comprobaciones en arduino/mando-joystick/README.md. | — |
| 53 | Instalar la recreativa en el equipo real (1 núcleo; 1 GB) | Físico | Eneko.S | 30/10 | Pendiente | Mismo preseed y script que la VM (tarea 16) o Batocera si se elige en la 51. | — |
| 13 | Bastionado de los 2 TPV Windows en VM (usuario estándar; kiosko; USB) | Software | Iker | 02/11 | Pendiente | Sin empezar: no hay VM de TPV ni script. Pasa de Markel a Iker. | — |
| 41 | Datos de prueba y consultas | Software | Iker | 02/11 | Pendiente | Comprobado el 23/10: los scripts no cargan datos (0 filas). Faltan los INSERT y consultas con JOIN; agregación y subconsulta. | — |
| 21 | Pruebas del stick con MAME y otro emulador | Físico | Markel | 03/11 | Pendiente | Pasa de Eneko.P a Markel. | — |
| 25 | WDS con segundo router y pruebas de cobertura | Físico | Peio | 03/11 | Pendiente | — | — |
| 15 | Scripts de configuración reproducibles (Windows) | Software | Iker | 04/11 | Pendiente | Linux ya tiene scripts (recreativa; Odoo; RAID; backup). Faltan los de Windows (gerente y TPV). Pasa de Eneko.S a Iker. | — |
| 52 | Proxy HTTPS delante de Odoo | Software | Adrian | 04/11 | Pendiente | Cifra el acceso de los TPV y del gerente y permite que el TPV siga cobrando sin red (service worker). | — |
| 54 | Medir rendimiento y recursos en el equipo real | Físico | Eneko.S | 04/11 | Pendiente | Con medir-rendimiento.sh y monitor-recreativa.sh. | — |
| 26 | Análisis de conectividad (Wireshark; nmap) | Físico | Eneko.S | 05/11 | Pendiente | Se puede adelantar con el fichero de Packet Tracer de la tarea 23. | — |
| 31 | IaC y despliegue automatizado (Terraform + Actions) | Software | Iker | 05/11 | Pendiente | iac/ está vacío. Recursos a crear: docs/web/30-hosting-aws.md; sección 9. | — |
| 36 | Importar y exportar datos en Odoo | Software | Iker | 05/11 | Pendiente | Pasa de Peio a Iker. | — |
| 37 | Imprimir ticket desde el TPV de Odoo en la impresora real | Físico | Peio | 05/11 | Pendiente | El ticket ya sale en pantalla (tarea 34; sección 8). Falta imprimirlo en la térmica. Pasa de Eneko.P a Peio. | — |
| 46 | Revisión de seguridad transversal | Software | Adrian | 06/11 | Pendiente | Puntos ya conocidos: Odoo sin HTTPS; root de Batocera con contraseña por defecto; red de invitados y WPA3; contraseñas débiles en la VM del gerente. Pasa de Eneko.S a Adrian. | — |
| 47 | Tabla de pruebas por bloque | Documentación | Eneko.S | 09/11 | Pendiente | Punto de partida: las pruebas del 23/10 en verificacion.md. Pasa de Eneko.P a Eneko.S. | [verificacion.md](../../docs/gestion/verificacion.md) |
| 48 | Documentación final paso a paso | Documentación | Markel | 10/11 | Pendiente | Punto de partida: LOGICA_RETO.md. | [LOGICA_RETO.md](../../LOGICA_RETO.md) |
| 49 | Presentación y ensayo | Documentación | Peio | 10/11 | Pendiente | — | — |

## Tareas hechas

| # | Tarea | Bloque | Tipo | Responsable | Revisa | Comprobación | Evidencia |
|---|---|---|---|---|---|---|---|
| 1 | Firmar Anexo I (contrato de equipo) | 0 Gestión | Gestión | Adrian | Equipo | Firmado el 21/10. | [anexo-I-contrato-equipo.md](../../docs/gestion/anexo-I-contrato-equipo.md) |
| 3 | Repartir tareas y responsables | 0 Gestión | Gestión | Adrian | Equipo | Reparto revisado el 23/10: software pendiente a Adrian e Iker; montaje físico a cualquiera salvo Eneko.P. | [roles.md](../../docs/gestion/roles.md) |
| 7 | Definir necesidades de equipos (gerente; 2 TPV; impresoras) | 1 Hardware | Documentación | Eneko.S | Iker | Requisitos RG, RT y RI con su prueba prevista. | [07-necesidades-equipos.md](../../docs/hardware/07-necesidades-equipos.md) |
| 8 | Tabla de hardware con justificación | 1 Hardware | Documentación | Eneko.S | Peio | Total de 2.361,36 € comprobado el 23/10. | [08-tabla-hardware.md](../../docs/hardware/08-tabla-hardware.md) |
| 9 | Tabla de software y licencias | 1 Hardware | Documentación | Markel | Iker | Falta indicar la versión concreta de cada programa (el plan la pide). | [09-tabla-software-licencias.md](../../docs/hardware/09-tabla-software-licencias.md) |
| 10 | Presupuesto con enlaces (incl. WAN y router extra) | 1 Hardware | Documentación | Peio | Eneko.S | Sumas comprobadas el 23/10 (2.447,34 € de inversión y 3.035,46 € el primer año). Incoherencia: presupuesta Telefónica 600 Mb y la tarea 22 elige DIGI 1 Gb; hay que unificarlo. | [10-presupuesto-hardware.md](../../docs/hardware/10-presupuesto-hardware.md) |
| 16 | Instalar SO ligero y MAME con arranque directo (VM) | 3 Arcade | Software | Iker | Markel | Debian 13 + MAME 0.276 en VM: arranque directo en 4,7 s y 5 ROMs legales verificadas. La instalación en el equipo real es la tarea 53. | [DOCUMENTACION.md](../../docs/arcade/16-recreativa-mame/DOCUMENTACION.md) |
| 20 | Firmware HID y mapeo configurable (EEPROM) | 4 Arduino | Software | Adrian | Iker | Compila (pio run del 23/10: Flash 37 %; RAM 17 %). Probarlo en la placa es la tarea 50. | [README.md](../../arduino/mando-joystick/README.md) |
| 22 | Comparativa de operadores WAN | 5 Redes | Documentación | Markel | Eneko.S | Elige DIGI 1 Gb (30 €/mes). No coincide con el presupuesto (tarea 10). | [22-comparativa-wan.md](../../docs/redes/22-comparativa-wan.md) |
| 23 | Plano del local y plan de direccionamiento IP | 5 Redes | Documentación | Adrian | Iker | Plano; plan de IP; segmentación y simulación en Packet Tracer con 8 pruebas y prueba HTTP. Falta la revisión de Iker. Las MAC se apuntan al montar (tarea 24). | [23-plano-direccionamiento.md](../../docs/redes/23-plano-direccionamiento.md) |
| 27 | Wireframes y diseño conceptual web | 6 Web | Documentación | Peio | Eneko.S | — | [27-wireframes.md](../../docs/web/27-wireframes.md) |
| 28 | Implementar web (mapa; formulario; slideshow) | 6 Web | Software | Markel | Eneko.S | Mapa de OpenStreetMap; geolocalización; formulario de ejemplo y slideshow. | [index.html](../../web/index.html) |
| 29 | Validación W3C; Lighthouse y accesibilidad | 6 Web | Software | Adrian | Peio | Lighthouse 98-100. W3C repetido el 23/10: 0 errores en HTML y en CSS. Pasa de Eneko.P a Adrian, que la hizo. | [lighthouse-w3c.txt](../../docs/evidencias/web/lighthouse-w3c.txt) |
| 30 | Hosting AWS con dominio y HTTPS | 6 Web | Software | Adrian | Iker | Probado con el laboratorio encendido (evidencias del 23/10). Fuera de sesión no responde porque el Learner Lab apaga la EC2. Configuración de nginx comprobada con nginx -t. | [30-hosting-aws.md](../../docs/web/30-hosting-aws.md) |
| 32 | Comparativa y elección de ERP | 7 ERP | Documentación | Eneko.S | Markel | Elige Odoo Community. | [32-comparativa-erp.md](../../docs/erp/32-comparativa-erp.md) |
| 33 | Instalar Odoo + PostgreSQL con Docker | 7 ERP | Software | Iker | Peio | Repetido el 23/10 en Docker limpio con el mismo docker-compose.yml: login 200; gestor de BD desactivado; 5432 sin publicar; admin/admin rechazado. | [DOCUMENTACION.md](../../docs/erp/33-odoo-docker/DOCUMENTACION.md) |
| 34 | Configurar módulos de Odoo | 7 ERP | Software | Iker | Adrian | Hecha por Iker (estaba a nombre de Markel). La prueba en limpio del 23/10 encontró 2 fallos que impedían repetirla desde cero; corregidos (evidencias/prueba-instalacion-limpia.txt). TPV de barra probado con una venta real. | [DOCUMENTACION.md](../../docs/erp/34-configurar-odoo/DOCUMENTACION.md) |
| 35 | Caso de uso end-to-end automatizado | 7 ERP | Software | Iker | Adrian | Pedido; factura; cobro y PDF. Repetido el 23/10 en limpio. No incluye envío por correo ni descuento de stock (el plan los ponía de ejemplo; el enunciado pide al menos un caso). | [DOCUMENTACION.md](../../docs/erp/35-factura-automatica/DOCUMENTACION.md) |
| 38 | Modelo E/R | 8 BD | Documentación | Adrian | Peio | — | [38-modelo-er.md](../../docs/bd/38-modelo-er.md) |
| 39 | Modelo lógico normalizado (3FN) | 8 BD | Documentación | Eneko.S | Peio | — | [39-modelo-logico-3fn.md](../../docs/bd/39-modelo-logico-3fn.md) |
| 40 | Scripts DDL | 8 BD | Software | Eneko.S | Adrian | Repetido el 23/10 en PostgreSQL 16: 01 a 03 sin errores; 03 repetible; 05-pruebas 33/33 dos veces; 04 borra y se puede recrear. | [40-scripts-ddl.md](../../docs/bd/40-scripts-ddl.md) |
| 43 | RAID 1 y simulación de fallo | 9 Backup | Software | Iker | Adrian | Hecha por Iker en VM (estaba a nombre de Eneko.P). | [DOCUMENTACION.md](../../docs/backup/43-raid1/DOCUMENTACION.md) |
| 45 | Prueba de restauración con evidencias | 9 Backup | Software | Iker | Markel | Restaurada la copia del USB en un entorno aislado; RTO 46 s. | [DOCUMENTACION.md](../../docs/backup/45-restauracion/DOCUMENTACION.md) |

## Carga por persona

| Persona | Tareas | Sin terminar | Software sin terminar | Físicas sin terminar | Días-tarea | Revisiones | Bloques que toca |
|---|---|---|---|---|---|---|---|
| Adrian | 16 | 9 | 6 | 1 | 49 | 10 | 0, 2, 3, 4, 5, 6, 7, 8, 10 |
| Eneko.S | 9 | 4 | 0 | 3 | 17 | 8 | 1, 3, 5, 7, 8, 11 |
| Iker | 16 | 10 | 8 | 0 | 42 | 14 | 0, 1, 2, 3, 6, 7, 8, 9 |
| Markel | 6 | 3 | 0 | 2 | 15 | 11 | 1, 4, 5, 6, 11 |
| Peio | 7 | 5 | 0 | 3 | 14 | 8 | 0, 1, 5, 6, 7, 11 |

## Tareas por persona

### Adrian

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 1 | Firmar Anexo I (contrato de equipo) | 0 Gestión | Gestión | 21/10–21/10 | — | Equipo | Hecho |
| 2 | Mantener Anexo II (11 pasos) | 0 Gestión | Gestión | 21/10–10/11 | — | Iker | En curso |
| 3 | Repartir tareas y responsables | 0 Gestión | Gestión | 21/10–21/10 | — | Equipo | Hecho |
| 5 | Repo con estructura y gitleaks; commits de todos | 0 Gestión | Gestión | 21/10–22/10 | — | Iker | En curso |
| 12 | Dual boot Win10 + Linux en el equipo del gerente (VM) | 2 SO | Software | 28/10–30/10 | #8 (Eneko.S) | Eneko.S | En curso |
| 14 | Driver y cola de la impresora de tickets en el TPV (VM) y prueba | 2 SO | Software | 29/10–30/10 | #8 (Eneko.S) | Eneko.S | Pendiente |
| 18 | Monitorización de recursos de la recreativa | 3 Arcade | Software | 30/10–02/11 | #16 (Iker) | Markel | En curso |
| 20 | Firmware HID y mapeo configurable (EEPROM) | 4 Arduino | Software | 27/10–30/10 | — | Iker | Hecho |
| 50 | Probar el firmware del stick en la placa (HID; comandos; EEPROM) | 4 Arduino | Físico | 28/10–30/10 | #19 (Markel) | Markel | Pendiente |
| 23 | Plano del local y plan de direccionamiento IP | 5 Redes | Documentación | 22/10–26/10 | — | Iker | Hecho |
| 29 | Validación W3C; Lighthouse y accesibilidad | 6 Web | Software | 02/11–03/11 | #28 (Markel) | Peio | Hecho |
| 30 | Hosting AWS con dominio y HTTPS | 6 Web | Software | 02/11–04/11 | #28 (Markel) | Iker | Hecho |
| 52 | Proxy HTTPS delante de Odoo | 7 ERP | Software | 03/11–04/11 | #33 (Iker) | Iker | Pendiente |
| 38 | Modelo E/R | 8 BD | Documentación | 22/10–23/10 | — | Peio | Hecho |
| 42 | Usuarios de BD con mínimos privilegios | 8 BD | Software | 02/11–03/11 | #40 (Eneko.S) | Iker | En curso |
| 46 | Revisión de seguridad transversal | 10 Seguridad | Software | 05/11–06/11 | #13 (Iker), #24 (Peio), #30 (Adrian), #42 (Adrian), #52 (Adrian) | Markel | Pendiente |

### Eneko.S

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 7 | Definir necesidades de equipos (gerente; 2 TPV; impresoras) | 1 Hardware | Documentación | 22/10–22/10 | — | Iker | Hecho |
| 8 | Tabla de hardware con justificación | 1 Hardware | Documentación | 23/10–26/10 | #7 (Eneko.S) | Peio | Hecho |
| 53 | Instalar la recreativa en el equipo real (1 núcleo; 1 GB) | 3 Arcade | Físico | 29/10–30/10 | #16 (Iker), #51 (Iker) | Iker | Pendiente |
| 54 | Medir rendimiento y recursos en el equipo real | 3 Arcade | Físico | 03/11–04/11 | #17 (Iker), #18 (Adrian), #53 (Eneko.S) | Iker | Pendiente |
| 26 | Análisis de conectividad (Wireshark; nmap) | 5 Redes | Físico | 04/11–05/11 | #25 (Peio) | Markel | Pendiente |
| 32 | Comparativa y elección de ERP | 7 ERP | Documentación | 22/10–23/10 | — | Markel | Hecho |
| 39 | Modelo lógico normalizado (3FN) | 8 BD | Documentación | 26/10–27/10 | #38 (Adrian) | Peio | Hecho |
| 40 | Scripts DDL | 8 BD | Software | 28/10–29/10 | #39 (Eneko.S) | Adrian | Hecho |
| 47 | Tabla de pruebas por bloque | 11 Entrega | Documentación | 06/11–09/11 | #21 (Markel), #26 (Eneko.S), #29 (Adrian) | Markel | Pendiente |

### Iker

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 4 | Crear tablero Kanban en GitHub Projects | 0 Gestión | Gestión | 26/10–27/10 | — | Adrian | Pendiente |
| 11 | Diagrama de arquitectura de equipos | 1 Hardware | Documentación | 27/10–28/10 | #8 (Eneko.S), #9 (Markel) | Adrian | En curso |
| 13 | Bastionado de los 2 TPV Windows en VM (usuario estándar; kiosko; USB) | 2 SO | Software | 28/10–02/11 | #9 (Markel) | Markel | Pendiente |
| 15 | Scripts de configuración reproducibles (Windows) | 2 SO | Software | 03/11–04/11 | #12 (Adrian), #13 (Iker) | Markel | Pendiente |
| 16 | Instalar SO ligero y MAME con arranque directo (VM) | 3 Arcade | Software | 26/10–28/10 | — | Markel | Hecho |
| 51 | Comparar Batocera con Debian en VM de 1 núcleo y 1 GB y decidir el SO | 3 Arcade | Software | 26/10–28/10 | — | Markel | En curso |
| 17 | Pruebas de rendimiento MAME antes/después (VM de 1 núcleo y 1 GB) | 3 Arcade | Software | 29/10–30/10 | #16 (Iker) | Adrian | En curso |
| 31 | IaC y despliegue automatizado (Terraform + Actions) | 6 Web | Software | 02/11–05/11 | #28 (Markel) | Adrian | Pendiente |
| 33 | Instalar Odoo + PostgreSQL con Docker | 7 ERP | Software | 26/10–28/10 | #32 (Eneko.S) | Peio | Hecho |
| 34 | Configurar módulos de Odoo | 7 ERP | Software | 29/10–02/11 | #33 (Iker) | Adrian | Hecho |
| 35 | Caso de uso end-to-end automatizado | 7 ERP | Software | 03/11–05/11 | #34 (Iker) | Adrian | Hecho |
| 36 | Importar y exportar datos en Odoo | 7 ERP | Software | 04/11–05/11 | #34 (Iker) | Peio | Pendiente |
| 41 | Datos de prueba y consultas | 8 BD | Software | 30/10–02/11 | #40 (Eneko.S) | Eneko.S | Pendiente |
| 43 | RAID 1 y simulación de fallo | 9 Backup | Software | 29/10–02/11 | — | Adrian | Hecho |
| 44 | Plan de backup 3-2-1 cifrado y automatizado | 9 Backup | Software | 03/11–04/11 | #41 (Iker), #43 (Iker) | Eneko.S | En curso |
| 45 | Prueba de restauración con evidencias | 9 Backup | Software | 05/11–06/11 | #44 (Iker) | Markel | Hecho |

### Markel

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 9 | Tabla de software y licencias | 1 Hardware | Documentación | 23/10–26/10 | #7 (Eneko.S) | Iker | Hecho |
| 19 | Montaje del arcade stick (ATmega32U4) | 4 Arduino | Físico | 26/10–27/10 | — | Peio | Pendiente |
| 21 | Pruebas del stick con MAME y otro emulador | 4 Arduino | Físico | 02/11–03/11 | #19 (Markel), #20 (Adrian), #50 (Adrian), #53 (Eneko.S) | Iker | Pendiente |
| 22 | Comparativa de operadores WAN | 5 Redes | Documentación | 22/10–23/10 | — | Eneko.S | Hecho |
| 28 | Implementar web (mapa; formulario; slideshow) | 6 Web | Software | 26/10–30/10 | #27 (Peio) | Eneko.S | Hecho |
| 48 | Documentación final paso a paso | 11 Entrega | Documentación | 09/11–10/11 | #45 (Iker) | Peio | Pendiente |

### Peio

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 6 | Resolver dudas pendientes con el profesor | 0 Gestión | Gestión | 26/10–27/10 | — | Adrian | Pendiente |
| 10 | Presupuesto con enlaces (incl. WAN y router extra) | 1 Hardware | Documentación | 27/10–27/10 | #8 (Eneko.S), #9 (Markel), #22 (Markel) | Eneko.S | Hecho |
| 24 | Configurar red segura (WPA3; invitados; firewall) | 5 Redes | Físico | 28/10–30/10 | #23 (Adrian) | Adrian | En curso |
| 25 | WDS con segundo router y pruebas de cobertura | 5 Redes | Físico | 02/11–03/11 | #24 (Peio) | Iker | Pendiente |
| 27 | Wireframes y diseño conceptual web | 6 Web | Documentación | 22/10–23/10 | — | Eneko.S | Hecho |
| 37 | Imprimir ticket desde el TPV de Odoo en la impresora real | 7 ERP | Físico | 04/11–05/11 | #14 (Adrian), #34 (Iker) | Iker | Pendiente |
| 49 | Presentación y ensayo | 11 Entrega | Documentación | 09/11–10/11 | #46 (Adrian) | Equipo | Pendiente |
