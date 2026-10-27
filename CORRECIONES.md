# Correcciones del reto Almi-Chain

Revisión del repositorio contra el **enunciado** ([Reto_1_ASIR1_2026-2027.docx](Reto_1_ASIR1_2026-2027.docx)), la única fuente fiable. El reto va del **lunes 26/10 al jueves 12/11/2026**.

- **Aquí solo hay correcciones:** cosas hechas mal, pruebas que no demuestran lo que dicen, datos que faltan en tareas dadas por hechas y fallos de seguridad. **Lo que simplemente falta por hacer está en el [Gantt](docs/gestion/gantt.md)** (y en las observaciones del [backlog](docs/gestion/backlog-kanban.csv)), con su responsable y sus fechas.
- **Un punto no está corregido hasta que pasa su checklist de la [sección 6](#6-checklist-para-dar-algo-por-corregido)**: la general (6.1) y la de su bloque (6.2). Entonces se marca `[x]` con la fecha.
- La revisión original, con la explicación de cada fallo: `git show 215eac7:CORRECIONES.md`. Hasta el 26/10 este fichero también llevaba las tareas pendientes: `git show 5f49a31:CORRECIONES.md`.
- **Gravedad:** 🔴 grave (incumple el enunciado o es un fallo de seguridad) · 🟠 media · 🟢 leve.

---

## 0. Por persona

| Persona | Correcciones |
|---|---|
| **Adrian** | [4](#4-datos-que-faltan-en-tareas-hechas) VM del gerente (Windows Update y cifrado), publicar la web con las fotos locales, notación del E/R |
| **Iker** | [2.1](#21-contraseñas) clave SSH de la recreativa · [2.3](#23-menús-del-cajero-tarea-34) menús del cajero · [2.4](#24-cortafuegos-del-servidor) cortafuegos del servidor · [3.1](#31-la-bd-no-está-en-el-raid-tarea-43) RAID · [3.3](#33-factura-automática-con-el-caso-de-uso-antiguo-tarea-35) factura rectificativa · [3.5](#35-rto-medido-en-el-mismo-servidor-tarea-45) RTO · [4](#4-datos-que-faltan-en-tareas-hechas) `almi_chain` en el servidor |
| **Peio** | Nada en esta lista: sus tareas abiertas (24 y 25) están en el Gantt |
| **Eneko.P** | [3.2](#32-recreativa-medida-en-una-vm-que-no-es-la-del-enunciado-tarea-17) medidas de la recreativa en 1 núcleo y 1 GB |
| **Markel** | [4](#4-datos-que-faltan-en-tareas-hechas) edición de Windows de los TPV |
| **Todos** | [4](#4-datos-que-faltan-en-tareas-hechas) sus filas del registro de IA |

---

## 1. Ya corregido

| Bloque | Qué se corrigió |
|---|---|
| Seguridad | Contraseñas Wi-Fi y RADIUS tapadas en las capturas; preseed de la recreativa sin clave SSH fija y SSH sin contraseña; actualizaciones de seguridad de la recreativa a las 5:00; contraseñas robustas en la VM del gerente (tarea 55); contraseñas Wi-Fi y de administración del router cambiadas y en KeePassXC (26/10); contraseñas de Packet Tracer en KeePassXC (26/10); Drive sin ficheros de contraseñas (24/10); contraseña de restic en KeePassXC y borrada del PC del técnico (27/10); **Odoo por HTTPS** hecho y probado en VM (26/10; activarlo en el servidor del equipo es la tarea 52) |
| Redes | Tarea 22 con análisis de necesidades y esquema de conectividad; tarea 23 con cita literal, invitados en `192.168.50.0/24` y switch; **red plana con invitados aislada** decidida (24/10) y diseño antiguo con VLAN quitado (25/10); Packet Tracer de la red real con 16 de 16 pruebas ([evidencia](docs/redes/evidencias/23-red-local-configuracion-y-pruebas.txt)) |
| Hardware | Presupuesto completo; Windows 10 IoT LTSC para los TPV; versiones del software; WAN unificada en DIGI 1 Gb |
| Arduino | Firmware con palanca digital y botones 7-8; esquema con la palanca en A2-A5 |
| ERP | Caso de uso de la tarea 35 al 10 %; TicketBAI decidido; 2 fallos de los scripts de Odoo que impedían instalar en limpio; **factura de la tarea 35 repetida con el menú de grupo: `INV/2026/00004` = 660,00 €**, y el script fija el IVA en la línea y comprueba el total (Iker, 27/10) |
| BD | Datos, consultas y usuarios de `almi_chain` ejecutados con evidencias ([41](docs/bd/evidencias/41-datos-y-consultas.txt), [42](docs/bd/evidencias/42-usuarios-y-permisos.txt)) |
| Copias | Procedimiento para la BD en el RAID; aviso del USB; RTO real marcado como pendiente |
| Web | CSP y Permissions-Policy; distancia al local; créditos; contraste, favicon y W3C; evidencias repetidas contra la versión publicada y Lighthouse móvil de 70 a 94 cargando el mapa al pulsar (26/10) |
| Gestión | Fechas reales; responsables coherentes; Anexo II con requisitos separados; decisiones del equipo apuntadas; 14 enlaces rotos |

---

## 2. Seguridad

### 2.1 Contraseñas

- [ ] 🟢 **Recreativas instaladas con el preseed antiguo:** borrar la línea `recreativa-claude` de `~tecnico/.ssh/authorized_keys`.
  - **Quién:** Iker.

Lo demás de este apartado está corregido (sección 1). Limitar la administración del router a la MAC del gerente y apagar WPS es trabajo de la tarea 24, en el Gantt.

### 2.2 HTTPS en Odoo (tarea 52)

Corregido el 26/10 (sección 1). Activarlo en la `ServidorERP` del equipo es trabajo de la tarea 52 ([runbook](docs/erp/52-https-odoo/RUNBOOK.md)), en el Gantt.

### 2.3 Menús del cajero (tarea 34)

- [ ] 🟠 **El cajero ve más aplicaciones de las que necesita** (la tarea 34 está en Hecho). `restringir-menus-cajero.py`; entrar como `cajero1` y hacer la captura nueva (solo ve Punto de venta).
  - **Quién:** Iker.
  - 26/10: en la VM de la tarea 52, `cajero1` entra directo en *Punto de venta* por HTTPS ([evidencia 08](docs/erp/52-https-odoo/evidencias/08-tpv-cajero1-https.png)), pero la captura no enseña el menú de aplicaciones, que es lo que hay que demostrar. 27/10: añadido al [runbook de la 52](docs/erp/52-https-odoo/RUNBOOK.md#31-menús-del-cajero-corrección-23) (paso 3.1), con la contraseña leída del `.env` y las dos capturas que faltan.

### 2.4 Cortafuegos del servidor

- [ ] 🟠 **La red plana solo es segura si cada equipo filtra** ([tarea 23, 5.3](docs/redes/23-plano-direccionamiento.md#5-segmentación)), y el servidor aún no lo hace: `sudo docs/erp/33-odoo-docker/cortafuegos-servidor.sh` en `ServidorERP` y guardar `ufw status verbose`.
  - **Quién:** Iker.

---

## 3. Pruebas que no demuestran lo que dicen

### 3.1 La BD no está en el RAID (tarea 43)

- [ ] 🔴 **El RAID 1 no protege nada:** Docker (y la BD de Odoo) sigue en el disco del sistema, y el fallo se simuló sin Odoo funcionando. Mover la BD:
  ```bash
  sudo docs/backup/43-raid1/mover-docker-al-raid.sh | tee docs/backup/43-raid1/evidencias/10-docker-en-el-raid.txt
  ```
  Termina con «Listo» (data-root `/srv/datos/docker` y login de Odoo 200). Después, **repetir el fallo con Odoo funcionando**: quitar un disco (sección 4 de la [tarea 43](docs/backup/43-raid1/DOCUMENTACION.md)), hacer una venta en el TPV, comprobar que se guarda y reconstruir. Evidencia `11-fallo-con-odoo.txt`.
  - **Quién:** Iker.

### 3.2 Recreativa medida en una VM que no es la del enunciado (tarea 17)

- [ ] 🔴 **Las medidas de antes y después son de una VM de 2 núcleos y 1,5 GB**; el enunciado pide 1 núcleo y 1 GB. En `Recreativa-1GB` solo hay 3 medidas de antes (las de la tarea 51 también son sin optimizar). Hacer las 3 de después con el `optimizar-arcade.sh` nuevo y sustituir las tablas de la [tarea 17](docs/arcade/17-rendimiento-mame/DOCUMENTACION.md).
  - **Quién:** Eneko.P.

### 3.3 Factura automática con el caso de uso antiguo (tarea 35)

Corregido el 27/10 (sección 1). Queda un resto:

- [ ] 🟢 **`INV/2026/00003` salió por 654,55 €** (dos IVA en la línea) y está validada y cobrada: anularla con una **factura rectificativa** y guardar el PDF en las evidencias de la [tarea 35](docs/erp/35-factura-automatica/DOCUMENTACION.md).
  - **Quién:** Iker.

### 3.4 Evidencias de la web (tarea 30)

Corregido el 26/10 (sección 1).

### 3.5 RTO medido en el mismo servidor (tarea 45)

- [ ] 🟠 **Los 46 s de restauración son en un entorno aislado del mismo servidor**, no en una máquina nueva: no es el RTO real. Restaurar en una VM nueva desde cero ([tarea 45, sección 6](docs/backup/45-restauracion/DOCUMENTACION.md)) y cronometrar.
  - **Quién:** Iker.

---

## 4. Datos que faltan en tareas hechas

- [ ] 🟠 **Edición de Windows de los TPV** (IoT Enterprise LTSC 2021 o Pro + ESU) y su precio en las tareas 9 y 10. Las VM de la tarea 13 se hicieron con **Windows 11 Pro**, que no coincide con lo presupuestado: o se dice que la VM simula la edición elegida, o se cambian las tareas 9 y 10. **Quién:** Markel. (El driver de Epson ya no se apunta: las pruebas se hacen con la Samsung ML-1660, decisión del 27/10.)
- [ ] 🟠 **VM del gerente (tarea 12):** actualizaciones de Windows y evidencia de RG-05; BitLocker y LUKS (el disco confirma que no hay nada cifrado: no existe `/etc/crypttab`). Hacen falta la VM encendida y con red. **Quién:** Adrian.
  - [x] Versión de Ubuntu: **26.04.1 LTS**, imagen del 26/08/2026, leída del disco de la VM sin arrancarla y puesta en las tareas 12 y 9 (27/10, [evidencia](docs/evidencias/12-dual-boot/ubu-08-version-desde-disco.txt)).
- [ ] 🟠 **`almi_chain` en el servidor (tareas 40-42):** la base está probada pero no existe en `ServidorERP`. Crearla (comandos de la [tarea 40, sección 2](docs/bd/40-scripts-ddl.md)), cargar `08-usuarios.sql` con contraseñas de KeePassXC y lanzar `sudo systemctl start backup-odoo`: el log tiene que decir `Volcado almi_chain`. **Quién:** Iker.
- [ ] 🟠 **Registro de IA:** cada persona pone en sus filas qué comprobó a mano, en vez de «pendiente de revisar por el equipo». **Quién:** todos.
- [x] 🟢 **Imágenes de la web:** copiadas a `web/img/` en WebP, con su autor en los créditos y en `web/img/CREDITOS.txt`; la txuleta del carrusel ya no repite la portada (que eran costillas) y la tarta de queso es otra foto de autor conocido. La CSP del servidor deja de admitir `images.unsplash.com` (se aplica al reinstalar). Adrian, 27/10. **Falta publicarlo:** se sube solo al fusionar si los secretos del Learner Lab están al día; si no, con el laboratorio arrancado.
- [ ] 🟢 **Notación del E/R:** comprobarla con la rúbrica cuando salga. **Quién:** Adrian.

---

## 5. Cumplimiento del enunciado (27/10)

«Tarea» es una tarea pendiente del [Gantt](docs/gestion/gantt.md); «corr.» es una corrección de esta lista.

| Tarea del enunciado | Estado | Qué falta |
|---|---|---|
| Necesidades, configuración y presupuesto de equipos e impresoras | Hecho, con huecos | Corr. 4 (edición de Windows de los TPV) |
| Identificar y documentar el hardware necesario | Hecho | — |
| Identificar y documentar el software necesario | Hecho, con huecos | Corr. 4 (versión de Ubuntu y del driver) |
| Instalación, optimización y monitorización de la recreativa | Parcial | Corr. 3.2; tareas 18, 53 y 54 (la 51 decidió Debian + MAME) |
| Montaje y programación del arcade stick | Casi hecho: montado y probado en la placa, en Batocera y con la EEPROM (27/10) | Tarea 21 (MAME y otro emulador) |
| Identificar necesidades de comunicación | Hecho | — |
| Implementación y configuración de sistemas operativos | Casi hecho: TPV bastionados a mano (tarea 13) | Tarea 15 (`comprobar-tpv.ps1`) y S-20 de la tarea 46 |
| Restricción de cuentas y equipos (mínimos privilegios) | Parcial | Corr. 2.3; tarea 15 y S-20 |
| Diseño conceptual de la web | Hecho, a posteriori | — |
| Web accesible y por HTTPS | Hecho | — |
| Hosting en AWS con dominio propio y despliegue reproducible | Casi hecho | Tarea 31 |
| ERP + TPV con un caso de uso automatizado | Hecho: factura de 660,00 € (27/10) | Tarea 36 |
| Instalación y configuración de una impresora | Hecho: ticket de Odoo impreso desde el TPV (Samsung por IPP, tarea 37, 27/10) | Tarea 14: cola en los TPV reales |
| Modelo E/R y tablas | Hecho | Corr. 4 (notación) |
| Implementación de la BD y consulta de sus datos | Hecho | Corr. 4 (`almi_chain` en el servidor) |
| Configurar disco redundante | Parcial | Corr. 3.1 |
| Plan de copias y prueba de restauración | Hecho, con huecos | Corr. 3.5; tarea 44 |
| Seguridad por defecto en toda la solución | Parcial | Corr. 2; tareas 24 y 46 |
| Verificar con pruebas (funcionamiento, restauración, failover) | Parcial | Corr. 3.1; tareas 15, 21, 24, 25 y 47 |
| Documentación reproducible con diagramas | Casi hecho | Evidencias de lo que se ejecute |
| Seguimiento (Gantt o Kanban) y Git | Hecho, con huecos | Commits de Eneko.P (tarea 5) |
| Documentación y presentación | Pendiente | Tareas 48 y 49 |

**Redes, en concreto:**

| Pide el enunciado | Estado |
|---|---|
| Contratar una línea WAN | Hecho (DIGI 1 Gb, con análisis de necesidades) |
| Esquema de conectividad | Hecho ([tarea 22, sección 4](docs/redes/22-comparativa-wan.md#4-esquema-de-conectividad)) |
| Diagrama de la red (plano), cableado y Wi-Fi | Hecho: plano y Packet Tracer de la red real probado |
| Red configurada de forma segura | Parcial: contraseñas del router cambiadas; faltan corr. 2.4 y la tarea 24 (red de invitados, WPS y administración por MAC) |
| Segundo router por WDS, comprobando que funciona | Prueba de laboratorio hecha (27/10): el enlace WDS funciona. Falta con la red del proyecto y el aislamiento de invitados (tarea 25) |
| RA.7 de PAR: conectar redes privadas a públicas | Demostrado en Packet Tracer: NAT, WAN e Internet sin acceso a la LAN (pruebas 11 y 12) |

---

## 6. Checklist para dar algo por corregido

Un punto de esta lista **no está corregido porque se haya hecho**, sino cuando se puede **demostrar** que está bien. Para cada corrección: primero la checklist general (6.1) y después la de su bloque (6.2). Antes de la entrega, la final (6.3).

Quien hace la corrección repasa estas casillas antes de unir su PR: si alguna no se cumple, no se une.

### 6.1 Para cualquier corrección

- [ ] **Funciona de verdad:** se ha probado en el equipo, la VM o el servicio real, no solo en el papel. Si algo no se pudo probar, el documento lo dice con esas palabras.
- [ ] **Hay evidencia guardada** en la carpeta `evidencias/` de la tarea: salida del comando (`… | tee evidencias/NN-que-es.txt`) o captura. El nombre dice qué demuestra.
- [ ] **Las evidencias no tienen secretos:** en los `.txt`, ni contraseñas ni tokens; las capturas se abren **ampliadas** y se revisa cada campo (gitleaks no mira dentro de las imágenes: es lo que pasó con la contraseña Wi-Fi).
- [ ] **El documento de la tarea está al día:** estado, fecha, resultado de la prueba con el enlace a la evidencia y la sección «Pendiente» marcada.
- [ ] **Coherente con el resto:** si cambia un dato que aparece en otros sitios (una IP, un precio, un nombre, un estado), se busca y se cambia en todos con `git grep -n "dato antiguo"`. Sobre todo en LOGICA_RETO, Anexo II, diagramas y README.
- [ ] **CSV y Gantt:** estado y observación de la tarea en [`backlog-kanban.csv`](docs/gestion/backlog-kanban.csv) (si pasa a **Hecho**, la columna Evidencia apunta a un fichero que existe) y `python3 scripts/gantt.py` sin errores.
- [ ] **`bash scripts/verificar-repo.sh` termina con «Todo correcto».**
- [ ] **Si se usó IA,** una fila en el [registro de IA](docs/gestion/registro-ia.md) con lo que se comprobó a mano.
- [ ] **Pull Request** con el CI en verde (gitleaks y comprobaciones).
- [ ] **Marcado en esta lista** con `[x]` y la fecha.

### 6.2 Por bloque: cómo se comprueba que está bien

**Contraseñas (2.1)**
- [ ] Router: con la contraseña Wi-Fi **antigua** ya no se conecta; con la nueva sí. La contraseña de administración antigua tampoco entra.
- [ ] La administración del router solo abre desde el PC del gerente (desde otro equipo, rechazada).
- [ ] Las contraseñas nuevas están en KeePassXC y en ningún otro sitio (ni capturas, ni chats, ni ficheros de texto, ni Drive).
- [x] Restic: `ls tarea-44/.credenciales-backup` en el PC del técnico → «No existe» (27/10, Adrian).
- [ ] Restic, prueba de que la copia de KeePassXC es buena: en el servidor, `sudo restic -r /srv/datos/restic snapshots` sin el fichero de contraseña, pegando la de KeePassXC cuando la pida → lista las copias.

**HTTPS y menús del cajero (2.2 y 2.3)**
- [x] `activar-https.sh` termina con HTTPS 200, HTTP 301 y 8069 cerrado (VM de prueba, 26/10).
- [ ] Desde el TPV, `https://192.168.10.10`: candado **sin avisos**, y la huella del certificado coincide con la que dio el script.
- [x] Desde otro equipo de la LAN, `http://192.168.10.10:8069` no responde (VM de prueba, 26/10).
- [ ] Se puede hacer una venta completa en el TPV por HTTPS.
- [ ] Después del cambio, `sudo systemctl start backup-odoo` sigue terminando bien (`journalctl -u backup-odoo` → «Copia terminada correctamente»).
- [ ] `cajero1` solo ve **Punto de venta**; `gerente` sigue viendo todas sus aplicaciones. Captura de los dos.

**Cortafuegos del servidor (2.4)**
- [ ] `sudo ufw status verbose` → entrada `deny`, 22 solo desde `192.168.10.20`, 80/443 desde `192.168.10.0/24`, y sin la regla temporal de la IP de instalación (si la hubo).
- [ ] Desde el TPV, `ssh tecnico@192.168.10.10` → rechazado; desde el PC del gerente → entra.
- [ ] Odoo sigue funcionando por HTTPS desde el TPV.

**RAID, copias y BD (3.1, 3.5 y 4)**
- [ ] `cat /proc/mdstat` → `[UU]`.
- [ ] `sudo docker info` → *Docker Root Dir* es `/srv/datos/docker`, y en `sudo docker volume inspect odoo_odoo-db-data` el *Mountpoint* está dentro de `/srv/datos`.
- [ ] Tras `sudo reboot`, Odoo vuelve solo (Docker arranca después de montar el RAID).
- [ ] Con un disco del RAID quitado, una venta se guarda; tras reconstruir, `[UU]` otra vez y la venta sigue ahí.
- [ ] `sudo restic -r /srv/datos/restic ls latest | grep -E "tienda.dump|almi_chain.dump"` → salen los dos volcados.
- [ ] RTO real: está el tiempo cronometrado de una restauración en una **VM nueva**, y aparece en la tarea 45, LOGICA_RETO y el Anexo II.

**Recreativa (3.2)**
- [ ] La evidencia muestra que la VM es de **1 núcleo y 1 GB** (`nproc` → 1; `free -m` → unos 1000 MB en total) en las medidas de antes y de después.

**Factura automática (3.3)**
- [x] `660,00 €`, factura validada, cobrada y con PDF (`INV/2026/00004`, 27/10).

**Web (3.4 y 4)**
- [x] `curl -sI https://almichain1.duckdns.org | grep -i content-length` da el mismo número que `wc -c < web/index.html`. (26/10)
- [x] `curl -sI https://almichain1.duckdns.org` incluye `content-security-policy` y `permissions-policy`. (26/10)
- [x] La web carga **sin errores en la consola** del navegador (la CSP no bloquea las fotos ni el mapa). (26/10)
- [x] Lighthouse **contra la URL pública**: 90 o más en las cuatro categorías; W3C sin errores (26/10: móvil 94/100/100/100, escritorio 99/100/100/100).

**VM del gerente (4)**
- [ ] `lsb_release -d` en la tarea 12; historial de Windows Update con una actualización acumulativa; `manage-bde -status` con `C:` cifrada.

### 6.3 Antes de entregar

- [ ] `bash scripts/verificar-repo.sh` **con Docker** (incluye shellcheck, W3C y **gitleaks de todo el historial**) → «Todo correcto».
- [ ] Ninguna tarea en **Hecho** sin evidencia: `python3 scripts/gantt.py` no da errores y cada evidencia se abre.
- [ ] `git grep -n -i "pendiente" -- docs LOGICA_RETO.md`: cada «pendiente» que quede es real y está en esta lista o en el Gantt.
- [ ] Todas las capturas del repositorio revisadas ampliadas, una a una, buscando contraseñas, tokens, IP públicas propias o datos personales.
- [ ] README (número de tareas hechas), LOGICA_RETO y Anexo II dicen lo mismo que el CSV.
- [ ] Cada persona del equipo sabe explicar el NAT, la red de invitados, el WDS, el porqué de la red plana (tarea 23, apartado 5.3) y cómo se recupera una copia.
