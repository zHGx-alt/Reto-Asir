# Correcciones del reto Almi-Chain · Lista para el lunes 26/10/2026

Revisión del repositorio contra el **enunciado** ([Reto_1_ASIR1_2026-2027.docx](Reto_1_ASIR1_2026-2027.docx)), la única fuente fiable. El reto va del **lunes 26/10 al jueves 12/11/2026**.

- **Estado (24/10/2026, segunda tanda):** todo lo que se podía hacer sin el hardware, sin las VM y sin AWS **está hecho y comprobado**. Lo que queda es, sobre todo, **ejecutar** lo preparado en las VM y en el hardware, y guardar las evidencias. Cada punto lleva el comando, quién lo hace (según el [backlog](docs/gestion/backlog-kanban.csv)) y cuándo está terminado.
- Al terminar un punto: marcarlo `[x]` con la fecha, actualizar la observación del CSV y regenerar el Gantt (`python3 scripts/gantt.py`).
- La revisión original, con la explicación de cada fallo: `git show 215eac7:CORRECIONES.md`.
- **Gravedad:** 🔴 grave (incumple el enunciado o es un fallo de seguridad) · 🟠 media · 🟢 leve.

---

## 0. El lunes, por persona

| Persona | Primero (la mañana) | Después | Secciones |
|---|---|---|---|
| **Peio** | Cambiar la contraseña Wi-Fi expuesta y la de administración del TL-WR841N (15 min) | Archer C6: tarea 24 completa, red de invitados y WDS (tarea 25) | [2.1](#21-urgente-contraseñas), [4.3](#43-routers-reales-tareas-24-26) |
| **Iker** | Pasar la contraseña de restic a KeePassXC (5 min). En `ServidorERP`: `mover-docker-al-raid.sh`, repetir el fallo del RAID con Odoo en marcha y `cortafuegos-servidor.sh` | Crear `almi_chain` en el servidor; VM del TPV con `configurar-tpv.ps1`; `importar-exportar.py`; `restringir-menus-cajero.py`; factura automática nueva; medidas de la recreativa en 1 GB | [2.1](#21-urgente-contraseñas), [3](#3-datos-raid-copias-y-bd), [5](#5-tpv-e-impresora), [7](#7-erp-y-recreativa) |
| **Adrian** | Packet Tracer: construir la red real con [la guía](docs/redes/23-packet-tracer-red-local.md) (1 h 30 min) | `activar-https.sh` (tarea 52); `terraform apply` y secretos de GitHub (tarea 31); publicar la web y repetir curl y Lighthouse; VM del gerente | [4.2](#42-packet-tracer-tarea-23), [2.2](#22-https-en-odoo-y-menús-del-cajero), [6](#6-web-y-aws) |
| **Markel** | Montar el arcade stick con el [esquema nuevo](arduino/mando-joystick/esquema-conexiones.svg) (palanca en A2-A5) | Pruebas con MAME y otro emulador (tarea 21) | [5](#5-tpv-e-impresora) |
| **Eneko.S** | Revisar la tarea 41 (evidencias de la BD) y la 12 | Recreativa real (tarea 53) | [7](#7-erp-y-recreativa) |
| **Equipo** | Leer la decisión de red ([tarea 23, 5.2 y 5.3](docs/redes/23-plano-direccionamiento.md#52-decisión-red-plana-con-red-de-invitados-aislada-24102026)): afecta a cómo se defiende la seguridad | Revisar los PR pendientes | [4.1](#41-decisión-red-plana-con-invitados-aislada) |

---

## 1. Ya hecho (no hay que repetirlo)

### 1.1 Primera tanda (24/10)

| Bloque | Qué se hizo |
|---|---|
| Seguridad | Contraseñas Wi-Fi y RADIUS tapadas en las capturas; preseed de la recreativa sin clave SSH fija y SSH sin contraseña; actualizaciones de seguridad de la recreativa a las 5:00 |
| Redes | Tarea 22 con análisis de necesidades y esquema de conectividad; tarea 23 con cita literal, invitados en `192.168.50.0/24`, switch y opciones plana / VLAN; tarea 24 al día |
| Hardware | Presupuesto completo (3.814,74 €); Windows 10 IoT LTSC para los TPV; versiones del software |
| Arduino | Firmware con palanca digital y botones 7-8; compila |
| ERP | Caso de uso de la tarea 35 al 10 %; TicketBAI decidido |
| Copias | Procedimiento para la BD en el RAID; aviso del USB; RTO real marcado como pendiente |
| Web | CSP y Permissions-Policy; distancia al local; créditos |
| Gestión | Fechas reales; responsables coherentes; Anexo II con requisitos separados; decisiones del equipo (equipo de 6, DuckDNS, base central, TicketBAI, una VM, impresora del centro) |

### 1.2 Segunda tanda (24/10): todo listo para ejecutar

| Tarea | Qué hay | Cómo se ha comprobado |
|---|---|---|
| 41 · Datos y consultas | [`06-datos.sql`](docs/bd/scripts/06-datos.sql) y [`07-consultas.sql`](docs/bd/scripts/07-consultas.sql) | **Ejecutados** en PostgreSQL 18.3: 8 facturas, 12 consultas con resultados coherentes. [Evidencia](docs/bd/evidencias/41-datos-y-consultas.txt). Tarea en **Hecho** |
| 42 · Usuarios de BD | [`08-usuarios.sql`](docs/bd/scripts/08-usuarios.sql) y [`09-pruebas-usuarios.sql`](docs/bd/scripts/09-pruebas-usuarios.sql) | **Ejecutados**: 9/9 pruebas con `tpv_app` y con `informes`. [Evidencia](docs/bd/evidencias/42-usuarios-y-permisos.txt). Tarea en **Hecho** |
| Verificación | `scripts/verificar-repo.sh` prueba la BD también **sin Docker**, con un PostgreSQL local en un clúster temporal | Ejecutado: todo correcto |
| 13 y 15 · TPV | [`configurar-tpv.ps1`](docs/so/13-tpv/configurar-tpv.ps1), [`comprobar-tpv.ps1`](docs/so/13-tpv/comprobar-tpv.ps1) y [guía](docs/so/13-tpv/DOCUMENTACION.md) | Sintaxis comprobada; la comprobación se probó en un Windows 11 y da FALLO donde debe |
| 14 y 37 · Impresora | [Guía](docs/so/14-impresora/DOCUMENTACION.md) con pasos y pruebas | Espera a la impresora del centro |
| 23 · Red y Packet Tracer | **Decisión: red plana con invitados aislada** (VLAN como anexo) y [guía para simular la red real](docs/redes/23-packet-tracer-red-local.md): ISP, NAT, LAN, dos Wi-Fi, router 2 como puente, cortafuegos de cada equipo y 16 pruebas | No se puede editar el `.pkt` fuera de Packet Tracer |
| 31 · IaC | [Terraform](iac/README.md) (S3, SG, EC2, IP elástica, user_data) y [workflow](.github/workflows/desplegar-web.yml) que publica la web | `terraform validate` y `fmt` correctos; `user_data` generado pasa `bash -n` |
| 36 · Importar y exportar | [`carta.csv`](docs/erp/36-importar-exportar/carta.csv) e [`importar-exportar.py`](docs/erp/36-importar-exportar/importar-exportar.py) | `py_compile` |
| 34 · Menús del cajero | [`restringir-menus-cajero.py`](docs/erp/34-configurar-odoo/restringir-menus-cajero.py) (con `--deshacer`) | `py_compile` |
| 52 · HTTPS en Odoo | [Proxy nginx](docs/erp/52-https-odoo/DOCUMENTACION.md) con certificado propio; Odoo deja de escuchar en la LAN | `bash -n` |
| 43 · BD en el RAID | [`mover-docker-al-raid.sh`](docs/backup/43-raid1/mover-docker-al-raid.sh) | `bash -n` |
| 11 · Diagrama | Mermaid y **SVG regenerados**; tabla de guías de instalación por equipo | SVG válido y revisado a ojo |
| 19 · Stick | [Esquema](arduino/mando-joystick/esquema-conexiones.svg) con la palanca digital y los botones 7-8 | Revisado a ojo |
| 6 · Dudas | Decisiones apuntadas en el Anexo II (sección 5); tarea en **Hecho** | — |

---

## 2. Seguridad

### 2.1 Urgente: contraseñas

- [ ] 🔴 **Cambiar la contraseña Wi-Fi del TL-WR841N** (se leía en las capturas antiguas, que siguen en el historial de Git). Conectarse por cable, `http://192.168.1.1` → *Wireless → Wireless Security* → contraseña nueva de KeePassXC (20 caracteres o más) → *Save*. Si el router ya no se usa, apuntarlo y listo.
  - **Quién:** Peio · **Hecho cuando:** marcado en la [tarea 24, sección 12](docs/redes/24-red-segura/DOCUMENTACION.md#12-pendiente), sin captura de la contraseña.
- [ ] 🟠 **Contraseña de administración del router:** *System Tools → Password*, otra de KeePassXC; limitar la administración a la MAC del PC del gerente; captura sin la contraseña.
  - **Quién:** Peio.
- [ ] 🟠 **Contraseña de restic:** copiarla de `tarea-44/.credenciales-backup` (o `sudo cat /root/.config/backup-odoo/restic.pass` en el servidor) a una entrada de KeePassXC y **borrar** `.credenciales-backup`. La del servidor se queda: la necesita la copia nocturna.
  - **Quién:** Iker (con quien tenga la contraseña maestra del `.kdbx`).
- [ ] 🟢 Recreativas instaladas con el preseed antiguo: borrar la línea `recreativa-claude` de `~tecnico/.ssh/authorized_keys`.
  - **Quién:** Iker.
- [x] Drive revisado: no hay ningún `.txt` con contraseñas; el `.kdbx` no sirve sin su contraseña maestra (24/10).

### 2.2 HTTPS en Odoo y menús del cajero

- [ ] 🔴 **Activar HTTPS (tarea 52)** en `ServidorERP`, después de mover la BD al RAID (3.1):
  ```bash
  cd docs/erp/52-https-odoo && mkdir -p evidencias && sudo ./activar-https.sh 192.168.10.10 | tee evidencias/01-activar-https.txt
  ```
  **Hecho cuando:** el script dice HTTPS 200, HTTP 301 y 8069 cerrado, y se hacen las pruebas de la [sección 4 de la guía](docs/erp/52-https-odoo/DOCUMENTACION.md).
  - **Quién:** Adrian · Revisa Iker.
- [ ] 🟠 **Menús del cajero:** `ODOO_ADMIN_PASSWORD=... python3 docs/erp/34-configurar-odoo/restringir-menus-cajero.py`; entrar como `cajero1` y hacer la captura nueva (solo ve Punto de venta).
  - **Quién:** Iker · Revisa Adrian.
- [ ] 🟢 Revisión de seguridad transversal (tarea 46) cuando esté lo anterior. **Quién:** Adrian · Revisa Markel.

---

## 3. Datos: RAID, copias y BD

### 3.1 RAID y copias (tareas 43-45)

- [ ] 🔴 **Mover la BD al RAID** en `ServidorERP`:
  ```bash
  sudo docs/backup/43-raid1/mover-docker-al-raid.sh | tee docs/backup/43-raid1/evidencias/10-docker-en-el-raid.txt
  ```
  **Hecho cuando:** termina con «Listo» (data-root `/srv/datos/docker` y login de Odoo 200).
  - **Quién:** Iker · Revisa Adrian.
- [ ] 🔴 **Repetir el fallo del RAID con Odoo funcionando:** quitar un disco (sección 4 de la [tarea 43](docs/backup/43-raid1/DOCUMENTACION.md)), hacer una venta en el TPV y comprobar que se guarda; reconstruir. Evidencia `11-fallo-con-odoo.txt`. Después, tarea 43 a **Hecho**.
- [ ] 🔴 **Crear `almi_chain` en el servidor** (comandos de la [tarea 40, sección 2](docs/bd/40-scripts-ddl.md)), cargar `08-usuarios.sql` con contraseñas de KeePassXC y lanzar `sudo systemctl start backup-odoo`: el log tiene que decir `Volcado almi_chain`.
- [ ] 🟠 **RTO real:** restaurar en una VM nueva desde cero ([tarea 45, sección 6](docs/backup/45-restauracion/DOCUMENTACION.md)) y cronometrar.
- [ ] 🟢 Aviso por correo si la copia falla (`OnFailure=`). Mejora: tercer repositorio en S3.

### 3.2 Base de datos (tareas 41 y 42)

- [x] Datos, consultas, usuarios y pruebas ejecutados con evidencias (24/10). Solo falta crear la base en el servidor (3.1).
- [ ] 🟢 Pasar `bash scripts/verificar-repo.sh` en un equipo con Docker para tener también shellcheck, W3C y gitleaks.

---

## 4. Redes

### 4.1 Decisión: red plana con invitados aislada

- [x] **Decidido el 24/10/2026:** red plana para el personal y Wi-Fi de invitados aislada; la separación entre TPV, gerente y servidor la hace el cortafuegos de cada equipo. El diseño con VLAN queda como anexo de mejora. Motivos y cómo se cumple cada caso: [tarea 23, apartados 5.2 y 5.3](docs/redes/23-plano-direccionamiento.md#52-decisión-red-plana-con-red-de-invitados-aislada-24102026). Apuntado en el Anexo II.
- [ ] 🟠 **Cortafuegos del servidor** (parte de la decisión): `sudo docs/erp/33-odoo-docker/cortafuegos-servidor.sh` en `ServidorERP` y guardar `ufw status verbose`.
  - **Quién:** Iker · Revisa Adrian.

### 4.2 Packet Tracer (tarea 23)

- [ ] 🔴 **Construir `23-red-local.pkt`** con [23-packet-tracer-red-local.md](docs/redes/23-packet-tracer-red-local.md), partiendo de una copia del anexo: ISP e Internet, LAN e invitados con NAT en R1, SW1, Wi-Fi del personal y de invitados, router 2 como puente, cortafuegos de los equipos y seguridad (comandos listos para pegar). Hora y media.
- [ ] 🔴 **Las 16 pruebas** (sección 8 de la guía) con sus capturas, la captura `23-red-local.png` y la tabla de la tarea 23 actualizada.
  - **Quién (los dos):** Adrian · Revisa Iker.

### 4.3 Routers reales (tareas 24-26)

- [ ] 🟠 **Tarea 24 en el Archer C6:** LAN `192.168.10.0/24`, reservas DHCP, WPA3 (o WPA2/WPA3), WPS desactivado, renovación de la clave de grupo y modo sin 802.11b ([lista](docs/redes/24-red-segura/DOCUMENTACION.md#12-pendiente)).
  - **Quién:** Peio · Revisa Adrian.
- [ ] 🟠 **Red de invitados aislada** y pruebas 3 a 5 de la [tarea 23, sección 6](docs/redes/23-plano-direccionamiento.md#6-cómo-se-comprueba).
- [ ] 🔴 **WDS (tarea 25):** segundo router, cobertura, velocidad y si la red de invitados pasa por el enlace. Si no pasa, corregir los diagramas.
  - **Quién:** Peio · Revisa Iker.
- [ ] 🟢 Wireshark y nmap (tarea 26). **Quién:** Eneko.S · Revisa Markel.

---

## 5. TPV e impresora

- [ ] 🔴 **VM del TPV y bastionado (tareas 13 y 15):** Windows 10 (Pro o IoT Enterprise LTSC), red hacia `ServidorERP`, y los pasos 1 a 7 de la [guía](docs/so/13-tpv/DOCUMENTACION.md#4-procedimiento-unos-15-minutos-por-tpv). **Hecho cuando:** `comprobar-tpv.ps1` da **16 OK** y están las capturas de la sección 5 de la guía.
  - **Quién:** Iker · Revisa Markel.
- [ ] 🟠 **Decidir la edición de Windows de los TPV** (IoT Enterprise LTSC 2021 o Pro + ESU) y apuntarla en la tarea 9.
- [ ] 🔴 **Impresora (tareas 14 y 37)** cuando el centro la dé: [guía](docs/so/14-impresora/DOCUMENTACION.md), pasos 1 a 7.
  - **Quién:** Adrian (14) · Peio (37).
- [ ] 🔴 **Montar el arcade stick (tarea 19):** [esquema](arduino/mando-joystick/esquema-conexiones.svg) (palanca en A2-A5 y común a GND; botones en 2-7).
  - **Quién:** Markel · Revisa Peio.
- [ ] 🔴 **Firmware en la placa (tarea 50):** lista del [README](arduino/mando-joystick/README.md#pendiente-prueba-en-físico-tarea-50).
  - **Quién:** Adrian · Revisa Markel.
- [ ] 🔴 **Stick con MAME y otro emulador (tarea 21).** **Quién:** Markel · Revisa Iker.

---

## 6. Web y AWS

**Quién:** Adrian · Revisa Iker. Con el Learner Lab arrancado.

- [ ] 🟠 **IaC (tarea 31):** decidir si se recrea todo con Terraform (borrar antes el montaje manual) o se deja el manual y Terraform queda probado en otra región o con otro nombre de bucket. Ejecutar `terraform apply` ([iac/README.md](iac/README.md), sección 4) y guardar la salida.
- [ ] 🟠 **Secretos de GitHub** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) para que `desplegar-web.yml` publique la web. Con eso, el próximo cambio en `web/` se publica solo.
- [ ] 🟠 **Publicar la versión actual** y volver a ejecutar `instalar-servidor-web.sh` (cabeceras nuevas), si no se usa Terraform.
- [ ] 🟠 **Pruebas contra la URL pública:** `curl -I https://almichain1.duckdns.org` (que `Content-Length` coincida con `web/index.html` y salgan CSP y Permissions-Policy), Lighthouse y W3C. Sustituir `08-pruebas-curl.txt` y `lighthouse-w3c.txt`.
- [ ] 🟢 Copiar las imágenes de Unsplash a `web/` (con su autor) y cambiar la primera foto del carrusel, que repite la de la portada.

---

## 7. ERP y recreativa

- [ ] 🟠 **Importar y exportar (tarea 36):** pasos 1 a 6 de la [guía](docs/erp/36-importar-exportar/DOCUMENTACION.md) contra `ServidorERP`, con evidencias.
  - **Quién:** Iker · Revisa Peio.
- [ ] 🟠 **Repetir la factura automática** con el menú de grupo (660,00 €) y cambiar las evidencias de la [tarea 35](docs/erp/35-factura-automatica/DOCUMENTACION.md).
  - **Quién:** Iker · Revisa Adrian.
- [ ] 🔴 **Recreativa en 1 núcleo y 1 GB (tarea 17):** 3 medidas antes y 3 después en `Recreativa-1GB` con el `optimizar-arcade.sh` nuevo; sustituir las tablas.
  - **Quién:** Iker · Revisa Adrian.
- [ ] 🟠 **Medir jugando (tarea 18):** `monitor-recreativa.sh` 10 minutos de partida ([protocolo](docs/arcade/18-monitorizacion-recreativa.md)), CSV a `docs/evidencias/18-monitorizacion/`.
  - **Quién:** Adrian · Revisa Markel.
- [ ] 🟠 **Debian o Batocera (tarea 51)** con esas medidas; apuntarlo en el Anexo II. **Quién:** Iker.
- [ ] 🟠 **Recreativa real (tarea 53)** y sus medidas (54). **Quién:** Eneko.S · Revisa Iker.
- [ ] 🟠 **VM del gerente (tarea 12):** versión exacta de Ubuntu (`lsb_release -d`) en las tareas 12 y 9; actualizaciones de Windows y evidencia de RG-05; BitLocker y LUKS. **Quién:** Adrian · Revisa Eneko.S.

---

## 8. Gestión

- [ ] 🟠 **Registro de IA:** cada persona cambia «pendiente de revisar por el equipo» en sus filas por lo que comprobó.
- [ ] 🟢 Revisar y aprobar los PR y documentos «pendiente de revisión» (tareas 7, 8, 11, 12, 23, 27, 30…).
- [ ] 🟢 Notación del E/R: revisar cuando salga la rúbrica.
- [ ] 🟢 Documentación final y presentación (tareas 48 y 49).

---

## 9. Cumplimiento del enunciado (24/10, tras la segunda tanda)

| Tarea del enunciado | Estado | Qué falta | Sección |
|---|---|---|---|
| Necesidades, configuración y presupuesto de equipos e impresoras | Hecho | Edición y precio de Windows de los TPV | 5 |
| Identificar y documentar el hardware necesario | Hecho | — | — |
| Identificar y documentar el software necesario | Hecho, con huecos | Versión de Ubuntu y del driver de la impresora | 7, 5 |
| Instalación, optimización y monitorización de la recreativa | Parcial | Medidas en 1 núcleo y 1 GB; monitorización jugando | 7 |
| Montaje y programación del arcade stick | Parcial | Montaje y prueba en placa (firmware y esquema listos) | 5 |
| Identificar necesidades de comunicación | Hecho | — | — |
| Implementación y configuración de sistemas operativos | Parcial | Ejecutar los scripts del TPV en la VM | 5 |
| Restricción de cuentas y equipos (mínimos privilegios) | Parcial | Ejecutar TPV y menús del cajero | 5, 2.2 |
| Diseño conceptual de la web | Hecho, a posteriori | — | — |
| Web accesible y por HTTPS | Hecho | Publicar la versión actual | 6 |
| Hosting en AWS con dominio propio y despliegue reproducible | Casi hecho | `terraform apply` y secretos de GitHub | 6 |
| ERP + TPV con un caso de uso automatizado | Hecho | Repetirlo con el caso de uso nuevo | 7 |
| Instalación y configuración de una impresora | Guía lista | Impresora del centro | 5 |
| Modelo E/R y tablas | Hecho | Notación, con la rúbrica | 8 |
| Implementación de la BD y consulta de sus datos | **Hecho** | Crear la base en el servidor | 3.1 |
| Configurar disco redundante | Parcial | **Ejecutar `mover-docker-al-raid.sh`** y repetir el fallo | 3.1 |
| Plan de copias y prueba de restauración | Hecho, con huecos | RTO en una máquina nueva | 3.1 |
| Seguridad por defecto en toda la solución | Parcial | Contraseñas del router; activar HTTPS en Odoo; red | 2, 4 |
| Verificar con pruebas (funcionamiento, restauración, failover) | Parcial | WDS; invitados; TPV; stick; fallo con Odoo en marcha | 3.1, 4.3, 5 |
| Documentación reproducible con diagramas | Casi hecho | Evidencias de lo que se ejecute | — |
| Seguimiento (Gantt o Kanban) y Git | Hecho, con huecos | Commits de Eneko.P | 8 |
| Documentación y presentación | Pendiente | Tareas 48 y 49 | 8 |

**Redes, en concreto:**

| Pide el enunciado | Estado |
|---|---|
| Contratar una línea WAN | Hecho (DIGI 1 Gb, con análisis de necesidades) |
| Esquema de conectividad | Hecho ([tarea 22, sección 4](docs/redes/22-comparativa-wan.md#4-esquema-de-conectividad)) |
| Diagrama de la red (plano), cableado y Wi-Fi | Plano hecho; Packet Tracer de la red real con la guía lista (4.2) |
| Red configurada de forma segura | Parcial: red decidida (4.1); faltan invitados en el router (4.3), cortafuegos del servidor (4.1) y contraseñas (2.1) |
| Segundo router por WDS, comprobando que funciona | Sin empezar (4.3) |
| RA.7 de PAR: conectar redes privadas a públicas | Se demuestra al construir la red real en Packet Tracer (NAT y WAN, 4.2) |
