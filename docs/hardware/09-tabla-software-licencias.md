# Tarea 9: Tabla de software y licencias

- **Bloque:** 1 Hardware
- **Responsable:** Markel
- **Depende de:** tarea 7 (necesidades de equipos)
- **Revisión:** 24/10/2026: versiones, software del servidor y de la recreativa, y licencia de Windows de los TPV

## 1. Objetivo

El enunciado pide *«detalles tanto del hardware como del software que se les va a instalar»*. Este documento indica el software de cada equipo del local (gerente, TPV, impresoras, servidor y recreativa) y de la web, con su **versión**, su licencia y su coste.

Las versiones son las que se han instalado y probado en las máquinas virtuales (se indica la evidencia). Donde todavía no hay instalación, se dice.

## 2. Puestos de trabajo

| Software | Versión | Equipo | Uso | Licencia | Cantidad | Coste |
| --- | --- | --- | --- | --- | --- | --- |
| Windows 10 Pro | 22H2 (la última de Windows 10; probada en la VM de la [tarea 12](../so/12-dual-boot.md)) | Gerente | Sistema operativo, directivas de seguridad y BitLocker | Propietaria (Microsoft) | 1 | Derecho de *downgrade* desde el Windows 11 Pro del equipo, a confirmar (H-01 de la tarea 8). Sin soporte gratuito desde el 14/10/2025 |
| Windows 10 IoT Enterprise LTSC 2021 *(propuesta)* o Windows 10 Pro 22H2 + ESU | 21H2 LTSC | 2 TPV | Sistema operativo, modo quiosco (Acceso asignado), directivas | Propietaria; la LTSC se vende con el equipo por canal OEM | 2 | A pedir al proveedor ([tarea 10](10-presupuesto-hardware.md), apartado 4.1). La LTSC tiene soporte hasta enero de 2032 |
| Ubuntu Desktop | 26.04.1 LTS ([tarea 12](../so/12-dual-boot.md)) | Gerente | Segundo sistema del arranque dual | Libre (GPL y otras) | 1 | 0 € |
| LibreOffice | La de los repositorios de Ubuntu | Gerente (Ubuntu) | Documentos, hojas de cálculo y presentaciones | Libre, MPL 2.0 | 1 | 0 € |
| Microsoft Edge | Canal estable, actualizado por Windows Update | Gerente y 2 TPV | Acceso a Odoo; navegador del modo quiosco en los TPV | Propietaria, incluida con Windows | 3 | 0 € adicional |
| Microsoft Defender y Firewall | Incluidos en Windows 10 | Gerente y 2 TPV | Antivirus y cortafuegos | Incluidos con Windows | 3 | 0 € adicional |
| KeePassXC | Última estable | Gerente | Gestor de contraseñas del proyecto (tarea 55) | Libre, GPL v3 | 1 | 0 € |
| Driver de Windows de Epson (APD) para TM-T20IV | A apuntar al instalarlo (tarea 14) | 2 TPV | Impresión de tickets y cortador automático | Del fabricante, gratuito | 2 | 0 € |

## 3. Servidor del local

| Software | Versión | Uso | Licencia | Coste | Evidencia |
| --- | --- | --- | --- | --- | --- |
| Debian GNU/Linux | 13 «Trixie», sin escritorio | Sistema del servidor | Libre | 0 € | [Tarea 33](../erp/33-odoo-docker/DOCUMENTACION.md) |
| Docker Engine y Docker Compose | 26.1.5 (paquete de Debian) y Compose 2.26 | Ejecutar Odoo y PostgreSQL en contenedores | Libre, Apache 2.0 | 0 € | [salida-desplegar-odoo.log](../erp/33-odoo-docker/evidencias/salida-desplegar-odoo.log) |
| Odoo Community | 19.0 (imagen `odoo:19.0`, compilación 19.0-20261015) | ERP y TPV del restaurante | Libre, LGPL v3 | 0 € | [Tarea 33](../erp/33-odoo-docker/DOCUMENTACION.md) |
| PostgreSQL | 17 (imagen `postgres:17`) | Base de datos de Odoo y base `almi_chain` (tareas 40 y 41) | Libre, licencia PostgreSQL | 0 € | [Tarea 33](../erp/33-odoo-docker/DOCUMENTACION.md) |
| mdadm | 4.4 | RAID 1 por software | Libre, GPL v2 | 0 € | [02-crear-raid.log](../backup/43-raid1/evidencias/02-crear-raid.log) |
| restic | 0.18.0 | Copias cifradas 3-2-1 | Libre, BSD-2 | 0 € | [01-instalar-backup.log](../backup/44-backup-3-2-1/evidencias/01-instalar-backup.log) |

## 4. Recreativa

| Software | Versión | Uso | Licencia | Coste | Evidencia |
| --- | --- | --- | --- | --- | --- |
| Debian GNU/Linux | 13.7 «Trixie», kernel 6.12, sin escritorio | Sistema mínimo que arranca directamente en MAME | Libre | 0 € | [Tarea 16](../arcade/16-recreativa-mame/DOCUMENTACION.md) |
| MAME | 0.276 (repositorio de Debian) | Emulador de juegos arcade | Libre, GPL v2 o posterior | 0 € | [Tarea 16](../arcade/16-recreativa-mame/DOCUMENTACION.md) |
| Servidor X (Xorg) mínimo, Mesa y ALSA | Los de Debian 13 | Pantalla, gráficos y sonido de MAME | Libres (MIT y otras) | 0 € | [instalar-arcade.sh](../arcade/16-recreativa-mame/instalar-arcade.sh) |
| unattended-upgrades | El de Debian 13 | Actualizaciones de seguridad a las 5:00 (tarea 17) | Libre, GPL v2 | 0 € | [optimizar-arcade.sh](../arcade/17-rendimiento-mame/optimizar-arcade.sh) |
| ROMs | — | Solo las 5 que publica el equipo de MAME con permiso de sus autores | Uso no comercial | 0 € | [Tarea 16](../arcade/16-recreativa-mame/DOCUMENTACION.md) |
| Batocera *(alternativa en estudio, tarea 51)* | Pendiente de decidir | Sistema todo en uno para emuladores | Libre | 0 € | [Notas](../arcade/16-batocera/NOTAS.md) |
| Firmware del arcade stick | Propio, compilado con PlatformIO para Arduino Leonardo | Joystick HID con mapeo en EEPROM | Propio del equipo | 0 € | [Firmware](../../arduino/mando-joystick/README.md) |

## 5. Web (AWS)

| Software | Versión | Uso | Licencia | Coste |
| --- | --- | --- | --- | --- |
| Ubuntu Server | 24.04 LTS (EC2) | Sistema del servidor web | Libre | Incluido en el Learner Lab |
| nginx | El de Ubuntu 24.04 | Servidor web con HTTPS | Libre, BSD-2 | 0 € |
| Certbot (Let's Encrypt) | El de Ubuntu 24.04 | Certificado HTTPS gratuito con renovación automática | Libre, Apache 2.0 | 0 € |
| AWS CLI | v2 | Sincronizar la web desde el bucket S3 | Libre, Apache 2.0 | 0 € |

## 6. Conclusión

- **Licencias de pago:** solo Windows. Una de Windows 10 Pro para el gerente (por *downgrade* desde el Windows 11 Pro del equipo, a confirmar) y dos para los TPV, que se proponen con **Windows 10 IoT Enterprise LTSC 2021** para tener actualizaciones de seguridad hasta 2032. Su precio se pide al proveedor y se añade al presupuesto (tarea 10).
- **Todo lo demás** es software libre o viene incluido con Windows o con las impresoras: el ERP, la base de datos, las copias, la recreativa y la web no tienen coste de licencia.
- **Pendiente:** nada de versiones. La de Ubuntu (26.04.1 LTS) se leyó del disco de la VM el 27/10; la del driver de Epson ya no se apunta porque las pruebas se hacen con la Samsung ML-1660 (decisión del 27/10).
