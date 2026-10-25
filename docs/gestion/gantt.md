# Planificación · Diagrama de Gantt

Del 21/10/2026 al 10/11/2026 (15 días laborables).

> Fichero generado con `python3 scripts/gantt.py` a partir de [backlog-kanban.csv](backlog-kanban.csv). Para cambiar fechas o responsables, edita el CSV y vuelve a generarlo.

> **Fechas.** En las tareas *Hecho*, Inicio y Fin son las fechas **reales** en que se hicieron (sacadas de los documentos y del historial de Git); en el resto, las planificadas. El reto va del lunes 26/10 al jueves 12/11/2026; la planificación actual vale y se revisará cuando salga la rúbrica (decisión del 24/10/2026).

![Diagrama de Gantt](gantt.svg)

Cada barra tiene el color de su responsable. La columna *Necesita* indica qué tareas tienen que estar terminadas antes de empezar.

## ⚠️ Avisos de dependencias

Tareas que empiezan antes de que acabe una tarea que necesitan:

- #8 (Tabla de hardware con justificación) empieza el 22/10 y necesita #7 (Definir necesidades de equipos (gerente; 2 TPV; impresoras)), que acaba el 22/10
- #9 (Tabla de software y licencias) empieza el 22/10 y necesita #7 (Definir necesidades de equipos (gerente; 2 TPV; impresoras)), que acaba el 22/10
- #10 (Presupuesto con enlaces (incl. WAN y router extra)) empieza el 22/10 y necesita #8 (Tabla de hardware con justificación), que acaba el 23/10
- #10 (Presupuesto con enlaces (incl. WAN y router extra)) empieza el 22/10 y necesita #9 (Tabla de software y licencias), que acaba el 23/10
- #10 (Presupuesto con enlaces (incl. WAN y router extra)) empieza el 22/10 y necesita #22 (Comparativa de operadores WAN), que acaba el 23/10
- #11 (Diagrama de arquitectura de equipos) empieza el 23/10 y necesita #8 (Tabla de hardware con justificación), que acaba el 23/10
- #11 (Diagrama de arquitectura de equipos) empieza el 23/10 y necesita #9 (Tabla de software y licencias), que acaba el 23/10
- #12 (Dual boot Win10 + Linux en el equipo del gerente (VM)) empieza el 22/10 y necesita #8 (Tabla de hardware con justificación), que acaba el 23/10
- #28 (Implementar web (mapa; formulario; slideshow)) empieza el 21/10 y necesita #27 (Wireframes y diseño conceptual web), que acaba el 23/10
- #29 (Validación W3C; Lighthouse y accesibilidad) empieza el 23/10 y necesita #28 (Implementar web (mapa; formulario; slideshow)), que acaba el 23/10
- #30 (Hosting AWS con dominio y HTTPS) empieza el 23/10 y necesita #28 (Implementar web (mapa; formulario; slideshow)), que acaba el 23/10
- #33 (Instalar Odoo + PostgreSQL con Docker) empieza el 22/10 y necesita #32 (Comparativa y elección de ERP), que acaba el 23/10
- #34 (Configurar módulos de Odoo) empieza el 22/10 y necesita #33 (Instalar Odoo + PostgreSQL con Docker), que acaba el 23/10
- #35 (Caso de uso end-to-end automatizado) empieza el 22/10 y necesita #34 (Configurar módulos de Odoo), que acaba el 23/10
- #39 (Modelo lógico normalizado (3FN)) empieza el 22/10 y necesita #38 (Modelo E/R), que acaba el 23/10
- #40 (Scripts DDL) empieza el 22/10 y necesita #39 (Modelo lógico normalizado (3FN)), que acaba el 23/10
- #41 (Datos de prueba y consultas) empieza el 23/10 y necesita #40 (Scripts DDL), que acaba el 23/10
- #42 (Usuarios de BD con mínimos privilegios) empieza el 23/10 y necesita #40 (Scripts DDL), que acaba el 23/10
- #45 (Prueba de restauración con evidencias) empieza el 22/10 y necesita #44 (Plan de backup 3-2-1 cifrado y automatizado), que acaba el 04/11

## Resumen

**29 de 55 tareas hechas (52 %).** *Hecho* significa que el entregable existe y tiene evidencias; las comprobaciones del 23/10/2026 están en [verificacion.md](verificacion.md).

| Tipo | Hechas | En curso | Pendientes | Total |
|---|---|---|---|---|
| Gestión | 4 | 2 | 0 | 6 |
| Documentación | 11 | 0 | 3 | 14 |
| Software | 14 | 10 | 2 | 26 |
| Físico | 0 | 1 | 8 | 9 |

*Software* se hace en un ordenador o en una máquina virtual; *Físico* necesita el equipo real (montar, cablear o configurar hardware).

## Tareas sin terminar

Ordenadas por estado y fecha de fin. *Qué falta* sale de revisar el documento de cada tarea.

| # | Tarea | Tipo | Responsable | Fin | Estado | Qué falta | Evidencia |
|---|---|---|---|---|---|---|---|
| 5 | Repo con estructura y gitleaks; commits de todos | Gestión | Adrian | 22/10 | En curso | Estructura, .gitignore y gitleaks hechos: CI en verde y gitleaks local sin fugas en 81 commits (23/10). Tienen commits 5 de 6 personas; falta Eneko.P (Anexo IX). | [gitleaks.yml](../../.github/workflows/gitleaks.yml) |
| 51 | Comparar Batocera con Debian en VM de 1 núcleo y 1 GB y decidir el SO | Software | Iker | 28/10 | En curso | Batocera arranca con 1 GB (565 MB usados solo con el menú). Faltan medidas; endurecimiento (root con contraseña por defecto) y la decisión en el Anexo II. | [NOTAS.md](../../docs/arcade/16-batocera/NOTAS.md) |
| 17 | Pruebas de rendimiento MAME antes/después (VM de 1 núcleo y 1 GB) | Software | Iker | 30/10 | En curso | Antes y después hechos en una VM de 2 núcleos y 1,5 GB. En la VM de 1 núcleo y 1 GB (la del enunciado) solo hay 3 medidas de antes; faltan las de después y medir jugando. El 24/10 optimizar-arcade.sh mantiene las actualizaciones de seguridad (a las 5:00). | [DOCUMENTACION.md](../../docs/arcade/17-rendimiento-mame/DOCUMENTACION.md) |
| 24 | Configurar red segura (WPA3; invitados; firewall) | Físico | Peio | 30/10 | En curso | Hecho en un TL-WR841N: administración remota cerrada; WPA2-AES; SPI y anti-DoS. Faltan la red de invitados aislada con su prueba; WPA3 (Archer C6); WPS; cambiar la contraseña de administración y la Wi-Fi (estaba visible en las capturas antiguas; tapadas el 24/10). | [DOCUMENTACION.md](../../docs/redes/24-red-segura/DOCUMENTACION.md) |
| 13 | Bastionado de los 2 TPV Windows en VM (usuario estándar; kiosko; USB) | Software | Iker | 02/11 | En curso | Scripts listos el 24/10 (configurar-tpv.ps1 y comprobar-tpv.ps1; sintaxis comprobada y la comprobación probada en un Windows 11). Falta crear la VM del TPV; ejecutar; poner el quiosco y guardar la evidencia. | [DOCUMENTACION.md](../../docs/so/13-tpv/DOCUMENTACION.md) |
| 18 | Monitorización de recursos de la recreativa | Software | Adrian | 02/11 | En curso | Scripts hechos y probados en Linux; documento reescrito para Debian el 24/10 (antes era para Batocera). Falta ejecutarlos en la VM de 1 GB durante una partida y guardar los CSV. Pasa de Eneko.S a Adrian. | [18-monitorizacion-recreativa.md](../../docs/arcade/18-monitorizacion-recreativa.md) |
| 43 | RAID 1 y simulación de fallo | Software | Iker | 02/11 | En curso | RAID y simulación de fallo hechos por Iker en VM (22-23/10). Falta lo principal: la BD sigue en el disco del sistema. mover-docker-al-raid.sh preparado el 24/10 (sección 7); falta ejecutarlo y repetir el fallo con Odoo funcionando. | [DOCUMENTACION.md](../../docs/backup/43-raid1/DOCUMENTACION.md) |
| 15 | Scripts de configuración reproducibles (Windows) | Software | Iker | 04/11 | En curso | configurar-tpv.ps1 y comprobar-tpv.ps1 hechos el 24/10 (tareas 13 y 15). Falta ejecutarlos en los dos TPV. | [configurar-tpv.ps1](../../docs/so/13-tpv/configurar-tpv.ps1) |
| 44 | Plan de backup 3-2-1 cifrado y automatizado | Software | Iker | 04/11 | En curso | Funciona para Odoo: cifrado; diario; RAID y USB. El 24/10 el script copia también almi_chain si existe y avisa si el USB lleva más de 7 días sin conectarse; falta probarlo en la VM. Pasa de Markel a Iker, que la hizo. | [DOCUMENTACION.md](../../docs/backup/44-backup-3-2-1/DOCUMENTACION.md) |
| 52 | Proxy HTTPS delante de Odoo | Software | Adrian | 04/11 | En curso | Proxy nginx con certificado propio preparado el 24/10 (docker-compose.https.yml; nginx.conf; activar-https.sh); Odoo deja de escuchar en la LAN. Falta ejecutarlo en la VM e instalar el certificado en los TPV (configurar-tpv.ps1 -CertificadoOdoo). | [DOCUMENTACION.md](../../docs/erp/52-https-odoo/DOCUMENTACION.md) |
| 31 | IaC y despliegue automatizado (Terraform + Actions) | Software | Iker | 05/11 | En curso | Terraform (S3; SG; EC2; IP elástica; user_data) y workflow desplegar-web.yml hechos el 24/10: terraform validate y fmt correctos; user_data con bash -n. Falta terraform apply en el Learner Lab y los secretos de AWS en GitHub. | [README.md](../../iac/README.md) |
| 36 | Importar y exportar datos en Odoo | Software | Iker | 05/11 | En curso | carta.csv (14 productos) e importar-exportar.py (importar carta; exportar carta; clientes; ventas y facturas a CSV) hechos el 24/10. Falta ejecutarlo contra Odoo y guardar las evidencias. | [DOCUMENTACION.md](../../docs/erp/36-importar-exportar/DOCUMENTACION.md) |
| 2 | Mantener Anexo II (11 pasos) | Gestión | Adrian | 10/11 | En curso | Dura todo el reto. Faltan las secciones 9 (entrega) y 10 (retrospectiva). | [anexo-II-11-pasos.md](../../docs/gestion/anexo-II-11-pasos.md) |
| 19 | Montaje del arcade stick (ATmega32U4) | Físico | Markel | 27/10 | Pendiente | Esquema de conexiones con la palanca digital (A2-A5) y botones 7-8 actualizado el 24/10. Falta cablear la placa y conseguir la palanca. | [esquema-conexiones.svg](../../arduino/mando-joystick/esquema-conexiones.svg) |
| 14 | Driver y cola de la impresora de tickets en el TPV (VM) y prueba | Software | Adrian | 30/10 | Pendiente | Guía lista el 24/10 (driver; predeterminada del cajero; pruebas). La impresora la da el centro: se hace cuando llegue. | [DOCUMENTACION.md](../../docs/so/14-impresora/DOCUMENTACION.md) |
| 50 | Probar el firmware del stick en la placa (HID; comandos; EEPROM) | Físico | Adrian | 30/10 | Pendiente | Lista de comprobaciones en arduino/mando-joystick/README.md. | — |
| 53 | Instalar la recreativa en el equipo real (1 núcleo; 1 GB) | Físico | Eneko.S | 30/10 | Pendiente | Mismo preseed y script que la VM (tarea 16) o Batocera si se elige en la 51. | — |
| 21 | Pruebas del stick con MAME y otro emulador | Físico | Markel | 03/11 | Pendiente | Pasa de Eneko.P a Markel. | — |
| 25 | WDS con segundo router y pruebas de cobertura | Físico | Peio | 03/11 | Pendiente | — | — |
| 54 | Medir rendimiento y recursos en el equipo real | Físico | Eneko.S | 04/11 | Pendiente | Con medir-rendimiento.sh y monitor-recreativa.sh. | — |
| 26 | Análisis de conectividad (Wireshark; nmap) | Físico | Eneko.S | 05/11 | Pendiente | Se puede adelantar con el fichero de Packet Tracer de la tarea 23. | — |
| 37 | Imprimir ticket desde el TPV de Odoo en la impresora real | Físico | Peio | 05/11 | Pendiente | El ticket ya sale en pantalla (tarea 34; sección 8). Pasos en docs/so/14-impresora/DOCUMENTACION.md (paso 6). Espera a la impresora del centro. | — |
| 46 | Revisión de seguridad transversal | Software | Adrian | 06/11 | Pendiente | Puntos ya conocidos: Odoo sin HTTPS; root de Batocera con contraseña por defecto; red de invitados y WPA3. Pasa de Eneko.S a Adrian. | — |
| 47 | Tabla de pruebas por bloque | Documentación | Eneko.S | 09/11 | Pendiente | Punto de partida: las pruebas del 23/10 en verificacion.md. Pasa de Eneko.P a Eneko.S. | [verificacion.md](../../docs/gestion/verificacion.md) |
| 48 | Documentación final paso a paso | Documentación | Markel | 10/11 | Pendiente | Punto de partida: LOGICA_RETO.md. | [LOGICA_RETO.md](../../LOGICA_RETO.md) |
| 49 | Presentación y ensayo | Documentación | Peio | 10/11 | Pendiente | — | — |

## Tareas hechas

| # | Tarea | Bloque | Tipo | Responsable | Revisa | Comprobación | Evidencia |
|---|---|---|---|---|---|---|---|
| 1 | Firmar Anexo I (contrato de equipo) | 0 Gestión | Gestión | Adrian | Equipo | Firmado el 21/10. | [anexo-I-contrato-equipo.md](../../docs/gestion/anexo-I-contrato-equipo.md) |
| 3 | Repartir tareas y responsables | 0 Gestión | Gestión | Adrian | Equipo | Reparto revisado el 23/10: software pendiente a Adrian e Iker; montaje físico a cualquiera salvo Eneko.P. | [roles.md](../../docs/gestion/roles.md) |
| 4 | Herramienta de seguimiento (Gantt en el repo) | 0 Gestión | Gestión | Iker | Adrian | El enunciado pide Gantt o Kanban: se usa el Gantt generado desde el CSV. El tablero de GitHub Projects se creó pero no se usa. | [gantt.md](../../docs/gestion/gantt.md) |
| 6 | Resolver dudas pendientes con el profesor | 0 Gestión | Gestión | Peio | Adrian | Decidido el 24/10 y apuntado en el Anexo II (sección 5): grupo de 6; DuckDNS vale; reto del 26/10 al 12/11; base central; TicketBAI sin configurar; una VM; la impresora la da el centro. La notación del E/R se revisa con la rúbrica. | [anexo-II-11-pasos.md](../../docs/gestion/anexo-II-11-pasos.md) |
| 7 | Definir necesidades de equipos (gerente; 2 TPV; impresoras) | 1 Hardware | Documentación | Eneko.S | Iker | Requisitos RG, RT y RI con su prueba prevista. | [07-necesidades-equipos.md](../../docs/hardware/07-necesidades-equipos.md) |
| 8 | Tabla de hardware con justificación | 1 Hardware | Documentación | Eneko.S | Peio | Total de 2.361,36 € comprobado el 23/10. | [08-tabla-hardware.md](../../docs/hardware/08-tabla-hardware.md) |
| 9 | Tabla de software y licencias | 1 Hardware | Documentación | Markel | Iker | Revisada el 24/10: versión de cada programa y software del servidor, la recreativa y la web. Faltan la versión exacta de Ubuntu (tarea 12) y la del driver de Epson (tarea 14). | [09-tabla-software-licencias.md](../../docs/hardware/09-tabla-software-licencias.md) |
| 10 | Presupuesto con enlaces (incl. WAN y router extra) | 1 Hardware | Documentación | Peio | Eneko.S | Sumas comprobadas el 23/10. El 24/10 se añaden servidor, discos del RAID, disco USB, SAI, switch, cable, adaptador Wi-Fi y palanca (sección 12): 3.814,74 € de inversión completa y 4.174,74 € el primer año. | [10-presupuesto-hardware.md](../../docs/hardware/10-presupuesto-hardware.md) |
| 11 | Diagrama de arquitectura de equipos | 1 Hardware | Documentación | Iker | Adrian | Actualizado el 24/10: switch; servidor presupuestado; red de invitados 192.168.50.0/24; Actions y HTTPS; SVG regenerado; tabla de guías de instalación por equipo. Falta la revisión de Adrian. | [DIAGRAMA.md](../../docs/diagramas/11-arquitectura-equipos/DIAGRAMA.md) |
| 12 | Dual boot Win10 + Linux en el equipo del gerente (VM) | 2 SO | Software | Adrian | Eneko.S | Hecho en VMware (23/10). Pendientes de la revisión del 24/10: versión exacta de Ubuntu; RG-05 de Windows queda parcial (ninguna actualización acumulativa instalada); cifrado después de instalar. Falta la revisión de Eneko.S. | [12-dual-boot.md](../../docs/so/12-dual-boot.md) |
| 16 | Instalar SO ligero y MAME con arranque directo (VM) | 3 Arcade | Software | Iker | Markel | Debian 13 + MAME 0.276 en VM: arranque directo en 4,7 s y 5 ROMs legales verificadas. El 24/10: preseed sin clave SSH fija y SSH sin contraseña; conexión a la Wi-Fi de invitados documentada. La instalación en el equipo real es la tarea 53. | [DOCUMENTACION.md](../../docs/arcade/16-recreativa-mame/DOCUMENTACION.md) |
| 20 | Firmware HID y mapeo configurable (EEPROM) | 4 Arduino | Software | Adrian | Iker | Compila (pio run del 24/10: Flash 39,9 %; RAM 19,3 %). Añadidos el modo de palanca digital de 4 microinterruptores y los botones 7-8. Probarlo en la placa es la tarea 50. | [README.md](../../arduino/mando-joystick/README.md) |
| 22 | Comparativa de operadores WAN | 5 Redes | Documentación | Markel | Eneko.S | Elige DIGI 1 Gb (30 €/mes). El 24/10 se añaden el análisis de necesidades y el esquema de conectividad. Es la WAN de todo el proyecto. | [22-comparativa-wan.md](../../docs/redes/22-comparativa-wan.md) |
| 23 | Plano del local y plan de direccionamiento IP | 5 Redes | Documentación | Adrian | Iker | Plano; plan de IP; red plana con invitados aislada (5.2 y 5.3) y VLAN como anexo. 23-red-local.pkt hecho el 25/10 (MCP de Packet Tracer y dos pasos a mano): 15 de 16 pruebas correctas; falta la captura del navegador (prueba 2). Falta la revisión de Iker. | [23-plano-direccionamiento.md](../../docs/redes/23-plano-direccionamiento.md) |
| 27 | Wireframes y diseño conceptual web | 6 Web | Documentación | Peio | Eneko.S | — | [27-wireframes.md](../../docs/web/27-wireframes.md) |
| 28 | Implementar web (mapa; formulario; slideshow) | 6 Web | Software | Markel | Eneko.S | Mapa de OpenStreetMap; geolocalización; formulario de ejemplo y slideshow. | [index.html](../../web/index.html) |
| 29 | Validación W3C; Lighthouse y accesibilidad | 6 Web | Software | Adrian | Peio | Lighthouse 98-100. W3C repetido el 23/10: 0 errores en HTML y en CSS. Pasa de Eneko.P a Adrian, que la hizo. | [lighthouse-w3c.txt](../../docs/evidencias/web/lighthouse-w3c.txt) |
| 30 | Hosting AWS con dominio y HTTPS | 6 Web | Software | Adrian | Iker | Probado con el laboratorio encendido (evidencias del 23/10). Fuera de sesión no responde porque el Learner Lab apaga la EC2. Configuración de nginx comprobada con nginx -t. | [30-hosting-aws.md](../../docs/web/30-hosting-aws.md) |
| 32 | Comparativa y elección de ERP | 7 ERP | Documentación | Eneko.S | Markel | Elige Odoo Community. | [32-comparativa-erp.md](../../docs/erp/32-comparativa-erp.md) |
| 33 | Instalar Odoo + PostgreSQL con Docker | 7 ERP | Software | Iker | Peio | Repetido el 23/10 en Docker limpio con el mismo docker-compose.yml: login 200; gestor de BD desactivado; 5432 sin publicar; admin/admin rechazado. | [DOCUMENTACION.md](../../docs/erp/33-odoo-docker/DOCUMENTACION.md) |
| 34 | Configurar módulos de Odoo | 7 ERP | Software | Iker | Adrian | Hecha por Iker (estaba a nombre de Markel). La prueba en limpio del 23/10 encontró 2 fallos que impedían repetirla desde cero; corregidos (evidencias/prueba-instalacion-limpia.txt). TPV de barra probado con una venta real. | [DOCUMENTACION.md](../../docs/erp/34-configurar-odoo/DOCUMENTACION.md) |
| 35 | Caso de uso end-to-end automatizado | 7 ERP | Software | Iker | Adrian | Pedido; factura; cobro y PDF (23/10 en limpio). El 24/10 el caso de uso pasa a un menú de grupo con IVA del 10 % (antes: partida recreativa al 21 %): hay que repetir la ejecución y cambiar las evidencias. | [DOCUMENTACION.md](../../docs/erp/35-factura-automatica/DOCUMENTACION.md) |
| 38 | Modelo E/R | 8 BD | Documentación | Adrian | Peio | — | [38-modelo-er.md](../../docs/bd/38-modelo-er.md) |
| 39 | Modelo lógico normalizado (3FN) | 8 BD | Documentación | Eneko.S | Peio | — | [39-modelo-logico-3fn.md](../../docs/bd/39-modelo-logico-3fn.md) |
| 40 | Scripts DDL | 8 BD | Software | Eneko.S | Adrian | Repetido el 23/10 en PostgreSQL 16: 01 a 03 sin errores; 03 repetible; 05-pruebas 33/33 dos veces; 04 borra y se puede recrear. | [40-scripts-ddl.md](../../docs/bd/40-scripts-ddl.md) |
| 41 | Datos de prueba y consultas | 8 BD | Software | Iker | Eneko.S | 06-datos.sql (2 locales; 8 ventas) y 07-consultas.sql (12 consultas) ejecutados el 24/10 en PostgreSQL 18.3 sin errores; evidencia guardada. Falta crear almi_chain en el servidor (tarea 40; sección 2). | [41-datos-y-consultas.txt](../../docs/bd/evidencias/41-datos-y-consultas.txt) |
| 42 | Usuarios de BD con mínimos privilegios | 8 BD | Software | Adrian | Iker | 08-usuarios.sql (tpv_app e informes con LOGIN; contraseñas por variable) y 09-pruebas-usuarios.sql: 9/9 con cada cuenta el 24/10. Pasa de Markel a Adrian. | [42-usuarios-y-permisos.txt](../../docs/bd/evidencias/42-usuarios-y-permisos.txt) |
| 45 | Prueba de restauración con evidencias | 9 Backup | Software | Iker | Markel | Restaurada la copia del USB en un entorno aislado del mismo servidor (46 s). Falta repetirla en una VM nueva para medir el RTO real. | [DOCUMENTACION.md](../../docs/backup/45-restauracion/DOCUMENTACION.md) |
| 55 | Contraseñas robustas en la VM del gerente y guardarlas en KeePassXC | 2 SO | Software | Adrian | Iker | 4 contraseñas cambiadas el 23/10 con frases generadas en KeePassXC; la cuenta de instalación de Windows ya no existe; VM exportada de nuevo. Drive revisado el 24/10: .vmdk y .kdbx nuevos y ningún .txt con contraseñas. | [ubu-07-cuentas-y-contrasenas.txt](../../docs/evidencias/12-dual-boot/ubu-07-cuentas-y-contrasenas.txt) |

## Carga por persona

| Persona | Tareas | Sin terminar | Software sin terminar | Físicas sin terminar | Días-tarea | Revisiones | Bloques que toca |
|---|---|---|---|---|---|---|---|
| Adrian | 17 | 7 | 4 | 1 | 42 | 10 | 0, 2, 3, 4, 5, 6, 7, 8, 10 |
| Eneko.S | 9 | 4 | 0 | 3 | 17 | 8 | 1, 3, 5, 7, 8, 11 |
| Iker | 16 | 8 | 8 | 0 | 42 | 15 | 0, 1, 2, 3, 6, 7, 8, 9 |
| Markel | 6 | 3 | 0 | 2 | 13 | 11 | 1, 4, 5, 6, 11 |
| Peio | 7 | 4 | 0 | 3 | 14 | 8 | 0, 1, 5, 6, 7, 11 |

## Tareas por persona

### Adrian

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 1 | Firmar Anexo I (contrato de equipo) | 0 Gestión | Gestión | 21/10–21/10 | — | Equipo | Hecho |
| 2 | Mantener Anexo II (11 pasos) | 0 Gestión | Gestión | 21/10–10/11 | — | Iker | En curso |
| 3 | Repartir tareas y responsables | 0 Gestión | Gestión | 21/10–21/10 | — | Equipo | Hecho |
| 5 | Repo con estructura y gitleaks; commits de todos | 0 Gestión | Gestión | 21/10–22/10 | — | Iker | En curso |
| 12 | Dual boot Win10 + Linux en el equipo del gerente (VM) | 2 SO | Software | 22/10–23/10 | #8 (Eneko.S) | Eneko.S | Hecho |
| 14 | Driver y cola de la impresora de tickets en el TPV (VM) y prueba | 2 SO | Software | 29/10–30/10 | #8 (Eneko.S) | Eneko.S | Pendiente |
| 55 | Contraseñas robustas en la VM del gerente y guardarlas en KeePassXC | 2 SO | Software | 23/10–23/10 | — | Iker | Hecho |
| 18 | Monitorización de recursos de la recreativa | 3 Arcade | Software | 30/10–02/11 | #16 (Iker) | Markel | En curso |
| 20 | Firmware HID y mapeo configurable (EEPROM) | 4 Arduino | Software | 22/10–23/10 | — | Iker | Hecho |
| 50 | Probar el firmware del stick en la placa (HID; comandos; EEPROM) | 4 Arduino | Físico | 28/10–30/10 | #19 (Markel) | Markel | Pendiente |
| 23 | Plano del local y plan de direccionamiento IP | 5 Redes | Documentación | 22/10–23/10 | — | Iker | Hecho |
| 29 | Validación W3C; Lighthouse y accesibilidad | 6 Web | Software | 23/10–23/10 | #28 (Markel) | Peio | Hecho |
| 30 | Hosting AWS con dominio y HTTPS | 6 Web | Software | 23/10–23/10 | #28 (Markel) | Iker | Hecho |
| 52 | Proxy HTTPS delante de Odoo | 7 ERP | Software | 03/11–04/11 | #33 (Iker) | Iker | En curso |
| 38 | Modelo E/R | 8 BD | Documentación | 22/10–23/10 | — | Peio | Hecho |
| 42 | Usuarios de BD con mínimos privilegios | 8 BD | Software | 23/10–23/10 | #40 (Eneko.S) | Iker | Hecho |
| 46 | Revisión de seguridad transversal | 10 Seguridad | Software | 05/11–06/11 | #13 (Iker), #24 (Peio), #30 (Adrian), #42 (Adrian), #52 (Adrian) | Markel | Pendiente |

### Eneko.S

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 7 | Definir necesidades de equipos (gerente; 2 TPV; impresoras) | 1 Hardware | Documentación | 22/10–22/10 | — | Iker | Hecho |
| 8 | Tabla de hardware con justificación | 1 Hardware | Documentación | 22/10–23/10 | #7 (Eneko.S) | Peio | Hecho |
| 53 | Instalar la recreativa en el equipo real (1 núcleo; 1 GB) | 3 Arcade | Físico | 29/10–30/10 | #16 (Iker), #51 (Iker) | Iker | Pendiente |
| 54 | Medir rendimiento y recursos en el equipo real | 3 Arcade | Físico | 03/11–04/11 | #17 (Iker), #18 (Adrian), #53 (Eneko.S) | Iker | Pendiente |
| 26 | Análisis de conectividad (Wireshark; nmap) | 5 Redes | Físico | 04/11–05/11 | #25 (Peio) | Markel | Pendiente |
| 32 | Comparativa y elección de ERP | 7 ERP | Documentación | 22/10–23/10 | — | Markel | Hecho |
| 39 | Modelo lógico normalizado (3FN) | 8 BD | Documentación | 22/10–23/10 | #38 (Adrian) | Peio | Hecho |
| 40 | Scripts DDL | 8 BD | Software | 22/10–23/10 | #39 (Eneko.S) | Adrian | Hecho |
| 47 | Tabla de pruebas por bloque | 11 Entrega | Documentación | 06/11–09/11 | #21 (Markel), #26 (Eneko.S), #29 (Adrian) | Markel | Pendiente |

### Iker

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 4 | Herramienta de seguimiento (Gantt en el repo) | 0 Gestión | Gestión | 21/10–23/10 | — | Adrian | Hecho |
| 11 | Diagrama de arquitectura de equipos | 1 Hardware | Documentación | 23/10–23/10 | #8 (Eneko.S), #9 (Markel) | Adrian | Hecho |
| 13 | Bastionado de los 2 TPV Windows en VM (usuario estándar; kiosko; USB) | 2 SO | Software | 28/10–02/11 | #9 (Markel) | Markel | En curso |
| 15 | Scripts de configuración reproducibles (Windows) | 2 SO | Software | 03/11–04/11 | #12 (Adrian), #13 (Iker) | Markel | En curso |
| 16 | Instalar SO ligero y MAME con arranque directo (VM) | 3 Arcade | Software | 22/10–23/10 | — | Markel | Hecho |
| 51 | Comparar Batocera con Debian en VM de 1 núcleo y 1 GB y decidir el SO | 3 Arcade | Software | 26/10–28/10 | — | Markel | En curso |
| 17 | Pruebas de rendimiento MAME antes/después (VM de 1 núcleo y 1 GB) | 3 Arcade | Software | 29/10–30/10 | #16 (Iker) | Adrian | En curso |
| 31 | IaC y despliegue automatizado (Terraform + Actions) | 6 Web | Software | 02/11–05/11 | #28 (Markel) | Adrian | En curso |
| 33 | Instalar Odoo + PostgreSQL con Docker | 7 ERP | Software | 22/10–23/10 | #32 (Eneko.S) | Peio | Hecho |
| 34 | Configurar módulos de Odoo | 7 ERP | Software | 22/10–23/10 | #33 (Iker) | Adrian | Hecho |
| 35 | Caso de uso end-to-end automatizado | 7 ERP | Software | 22/10–23/10 | #34 (Iker) | Adrian | Hecho |
| 36 | Importar y exportar datos en Odoo | 7 ERP | Software | 04/11–05/11 | #34 (Iker) | Peio | En curso |
| 41 | Datos de prueba y consultas | 8 BD | Software | 23/10–23/10 | #40 (Eneko.S) | Eneko.S | Hecho |
| 43 | RAID 1 y simulación de fallo | 9 Backup | Software | 22/10–02/11 | — | Adrian | En curso |
| 44 | Plan de backup 3-2-1 cifrado y automatizado | 9 Backup | Software | 03/11–04/11 | #41 (Iker), #43 (Iker) | Eneko.S | En curso |
| 45 | Prueba de restauración con evidencias | 9 Backup | Software | 22/10–23/10 | #44 (Iker) | Markel | Hecho |

### Markel

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 9 | Tabla de software y licencias | 1 Hardware | Documentación | 22/10–23/10 | #7 (Eneko.S) | Iker | Hecho |
| 19 | Montaje del arcade stick (ATmega32U4) | 4 Arduino | Físico | 26/10–27/10 | — | Peio | Pendiente |
| 21 | Pruebas del stick con MAME y otro emulador | 4 Arduino | Físico | 02/11–03/11 | #19 (Markel), #20 (Adrian), #50 (Adrian), #53 (Eneko.S) | Iker | Pendiente |
| 22 | Comparativa de operadores WAN | 5 Redes | Documentación | 22/10–23/10 | — | Eneko.S | Hecho |
| 28 | Implementar web (mapa; formulario; slideshow) | 6 Web | Software | 21/10–23/10 | #27 (Peio) | Eneko.S | Hecho |
| 48 | Documentación final paso a paso | 11 Entrega | Documentación | 09/11–10/11 | #45 (Iker) | Peio | Pendiente |

### Peio

| # | Tarea | Bloque | Tipo | Fechas | Depende de | Revisa | Estado |
|---|---|---|---|---|---|---|---|
| 6 | Resolver dudas pendientes con el profesor | 0 Gestión | Gestión | 23/10–23/10 | — | Adrian | Hecho |
| 10 | Presupuesto con enlaces (incl. WAN y router extra) | 1 Hardware | Documentación | 22/10–23/10 | #8 (Eneko.S), #9 (Markel), #22 (Markel) | Eneko.S | Hecho |
| 24 | Configurar red segura (WPA3; invitados; firewall) | 5 Redes | Físico | 28/10–30/10 | #23 (Adrian) | Adrian | En curso |
| 25 | WDS con segundo router y pruebas de cobertura | 5 Redes | Físico | 02/11–03/11 | #24 (Peio) | Iker | Pendiente |
| 27 | Wireframes y diseño conceptual web | 6 Web | Documentación | 22/10–23/10 | — | Eneko.S | Hecho |
| 37 | Imprimir ticket desde el TPV de Odoo en la impresora real | 7 ERP | Físico | 04/11–05/11 | #14 (Adrian), #34 (Iker) | Iker | Pendiente |
| 49 | Presentación y ensayo | 11 Entrega | Documentación | 09/11–10/11 | #46 (Adrian) | Equipo | Pendiente |
