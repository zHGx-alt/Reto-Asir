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
| **Adrian** | [4](#4-datos-que-faltan-en-tareas-hechas) VM del gerente, imágenes de la web, notación del E/R |
| **Iker** | [2.1](#21-contraseñas) restic y clave SSH de la recreativa · [2.3](#23-menús-del-cajero-tarea-34) menús del cajero · [2.4](#24-cortafuegos-del-servidor) cortafuegos del servidor · [3.1](#31-la-bd-no-está-en-el-raid-tarea-43) RAID · [3.3](#33-factura-automática-con-el-caso-de-uso-antiguo-tarea-35) factura · [3.5](#35-rto-medido-en-el-mismo-servidor-tarea-45) RTO · [4](#4-datos-que-faltan-en-tareas-hechas) `almi_chain` en el servidor |
| **Peio** | [2.1](#21-contraseñas) contraseña Wi-Fi y de administración del router |
| **Eneko.P** | [3.2](#32-recreativa-medida-en-una-vm-que-no-es-la-del-enunciado-tarea-17) medidas de la recreativa en 1 núcleo y 1 GB |
| **Markel** | [4](#4-datos-que-faltan-en-tareas-hechas) edición de Windows de los TPV y versión del driver |
| **Todos** | [4](#4-datos-que-faltan-en-tareas-hechas) sus filas del registro de IA |

---

## 1. Ya corregido

| Bloque | Qué se corrigió |
|---|---|
| Seguridad | Contraseñas Wi-Fi y RADIUS tapadas en las capturas; preseed de la recreativa sin clave SSH fija y SSH sin contraseña; actualizaciones de seguridad de la recreativa a las 5:00; contraseñas robustas en la VM del gerente (tarea 55) |
| Redes | Tarea 22 con análisis de necesidades y esquema de conectividad; tarea 23 con cita literal, invitados en `192.168.50.0/24` y switch; **red plana con invitados aislada** decidida (24/10) y diseño antiguo con VLAN quitado (25/10); Packet Tracer de la red real con 16 de 16 pruebas ([evidencia](docs/redes/evidencias/23-red-local-configuracion-y-pruebas.txt)) |
| Hardware | Presupuesto completo; Windows 10 IoT LTSC para los TPV; versiones del software; WAN unificada en DIGI 1 Gb |
| Arduino | Firmware con palanca digital y botones 7-8; esquema con la palanca en A2-A5 |
| ERP | Caso de uso de la tarea 35 al 10 %; TicketBAI decidido; 2 fallos de los scripts de Odoo que impedían instalar en limpio |
| BD | Datos, consultas y usuarios de `almi_chain` ejecutados con evidencias ([41](docs/bd/evidencias/41-datos-y-consultas.txt), [42](docs/bd/evidencias/42-usuarios-y-permisos.txt)) |
| Copias | Procedimiento para la BD en el RAID; aviso del USB; RTO real marcado como pendiente |
| Web | CSP y Permissions-Policy; distancia al local; créditos; contraste, favicon y W3C |
| Gestión | Fechas reales; responsables coherentes; Anexo II con requisitos separados; decisiones del equipo apuntadas; 14 enlaces rotos |

---

## 2. Seguridad

### 2.1 Contraseñas

- [ ] 🔴 **Contraseña Wi-Fi del TL-WR841N:** se leía en las capturas antiguas, que siguen en el historial de Git. Conectarse por cable, `http://192.168.1.1` → *Wireless → Wireless Security* → contraseña nueva de KeePassXC (20 caracteres o más) → *Save*. Si el router ya no se usa, apuntarlo y listo.
  - **Quién:** Peio · **Hecho cuando:** marcado en la [tarea 24, sección 12](docs/redes/24-red-segura/DOCUMENTACION.md#12-pendiente), sin captura de la contraseña.
- [ ] 🟠 **Contraseña de administración del router:** *System Tools → Password*, otra de KeePassXC; limitar la administración a la MAC del PC del gerente; captura sin la contraseña.
  - **Quién:** Peio.
- [ ] 🟠 **Contraseña de restic en texto plano:** copiarla de `tarea-44/.credenciales-backup` (o `sudo cat /root/.config/backup-odoo/restic.pass` en el servidor) a una entrada de KeePassXC y **borrar** `.credenciales-backup`. La del servidor se queda: la necesita la copia nocturna.
  - **Quién:** Iker (con quien tenga la contraseña maestra del `.kdbx`).
- [x] 🟢 **Contraseñas de Packet Tracer** (R1, SW1 y las Wi-Fi de prueba) en el Drive del grupo: pasadas a KeePassXC ([guía de la tarea 23](docs/redes/23-packet-tracer-red-local.md)). Adrian, 26/10.
- [ ] 🟢 **Recreativas instaladas con el preseed antiguo:** borrar la línea `recreativa-claude` de `~tecnico/.ssh/authorized_keys`.
  - **Quién:** Iker.
- [x] Drive revisado: no hay ningún `.txt` con contraseñas; el `.kdbx` no sirve sin su contraseña maestra (24/10).

### 2.2 HTTPS en Odoo (tarea 52)

- [x] 🔴 **Odoo va por HTTP en la LAN** (usuario y contraseña del cajero en claro). Corregido el 26/10: el proxy HTTPS funciona y está probado. Lo que queda (activarlo en la `ServidorERP` del equipo, después de mover la BD al RAID, y las pruebas 5 y 6 con el TPV) es trabajo de la tarea 52, en el [Gantt](docs/gestion/gantt.md):
  ```bash
  cd docs/erp/52-https-odoo && mkdir -p evidencias && sudo ./activar-https.sh 192.168.10.10 | tee evidencias/01-activar-https.txt
  ```
  **Hecho cuando:** el script dice HTTPS 200, HTTP 301 y 8069 cerrado, y se hacen las pruebas de la [sección 4 de la guía](docs/erp/52-https-odoo/DOCUMENTACION.md).
  - **Quién:** Adrian.
  - [x] Probado el 26/10 en una `ServidorERP` nueva (VM en el PC de Adrian): pasan todas las pruebas menos las del TPV (5 y 6). De paso se corrigieron el permiso de ejecución del script, las cabeceras duplicadas, la cookie de sesión sin `Secure` y el proxy que no cogía un `nginx.conf` nuevo ([incidencias](docs/erp/52-https-odoo/DOCUMENTACION.md#41-incidencias)). Falta ejecutarlo en la `ServidorERP` del equipo.

### 2.3 Menús del cajero (tarea 34)

- [ ] 🟠 **El cajero ve más aplicaciones de las que necesita** (la tarea 34 está en Hecho). `ODOO_ADMIN_PASSWORD=... python3 docs/erp/34-configurar-odoo/restringir-menus-cajero.py`; entrar como `cajero1` y hacer la captura nueva (solo ve Punto de venta).
  - **Quién:** Iker.

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

- [ ] 🔴 **Las medidas de antes y después son de una VM de 2 núcleos y 1,5 GB**; el enunciado pide 1 núcleo y 1 GB. En `Recreativa-1GB` solo hay 3 medidas de antes. Hacer las 3 de después con el `optimizar-arcade.sh` nuevo y sustituir las tablas de la [tarea 17](docs/arcade/17-rendimiento-mame/DOCUMENTACION.md).
  - **Quién:** Eneko.P.

### 3.3 Factura automática con el caso de uso antiguo (tarea 35)

- [ ] 🟠 **Las evidencias son de la partida recreativa al 21 %**, y el caso de uso es ahora el menú de grupo al 10 %. Repetir la ejecución (660,00 €) y cambiar las evidencias de la [tarea 35](docs/erp/35-factura-automatica/DOCUMENTACION.md).
  - **Quién:** Iker.

### 3.4 Evidencias de la web (tarea 30)

- [x] 🟠 **`08-pruebas-curl.txt` y `lighthouse-w3c.txt` son de una versión anterior** de la web, sin las cabeceras nuevas. Publicar la versión actual (con `desplegar-web.yml` si ya hay secretos, o a mano) y volver a ejecutar `instalar-servidor-web.sh`. Después, contra la URL pública: `curl -I https://almichain1.duckdns.org` (que `Content-Length` coincida con `web/index.html` y salgan CSP y Permissions-Policy), Lighthouse y W3C. Sustituir las dos evidencias.
  - **Quién:** Adrian. Con el Learner Lab arrancado.
  - [x] Publicada la versión actual y evidencias sustituidas (26/10): lo publicado es idéntico al repositorio, salen CSP y Permissions-Policy, W3C sin errores y escritorio 98-100 en Lighthouse.
  - [x] 🟠 **Lighthouse en móvil daba 70 de rendimiento** (mediana de 5; hace falta 90): el iframe del mapa de OpenStreetMap trae unos 1,3 MB de JavaScript y se carga dentro de la medida. Arreglado y publicado (26/10): el mapa se carga al pulsar «Ver el mapa»; contra la URL pública, móvil 94 y escritorio 99 (mediana de 5).

### 3.5 RTO medido en el mismo servidor (tarea 45)

- [ ] 🟠 **Los 46 s de restauración son en un entorno aislado del mismo servidor**, no en una máquina nueva: no es el RTO real. Restaurar en una VM nueva desde cero ([tarea 45, sección 6](docs/backup/45-restauracion/DOCUMENTACION.md)) y cronometrar.
  - **Quién:** Iker.

---

## 4. Datos que faltan en tareas hechas

- [ ] 🟠 **VM del gerente (tarea 12):** versión exacta de Ubuntu (`lsb_release -d`) en las tareas 12 y 9; actualizaciones de Windows y evidencia de RG-05; BitLocker y LUKS. **Quién:** Adrian.
- [ ] 🟠 **Edición de Windows de los TPV** (IoT Enterprise LTSC 2021 o Pro + ESU) y su precio en las tareas 9 y 10; versión del driver de Epson en la 9 cuando llegue la impresora. **Quién:** Markel.
- [ ] 🟠 **`almi_chain` en el servidor (tareas 40-42):** la base está probada pero no existe en `ServidorERP`. Crearla (comandos de la [tarea 40, sección 2](docs/bd/40-scripts-ddl.md)), cargar `08-usuarios.sql` con contraseñas de KeePassXC y lanzar `sudo systemctl start backup-odoo`: el log tiene que decir `Volcado almi_chain`. **Quién:** Iker.
- [ ] 🟠 **Registro de IA:** cada persona pone en sus filas qué comprobó a mano, en vez de «pendiente de revisar por el equipo». **Quién:** todos.
- [ ] 🟢 **Imágenes de la web:** copiar las de Unsplash a `web/` (con su autor) y cambiar la primera foto del carrusel, que repite la de la portada. **Quién:** Adrian.
- [ ] 🟢 **Notación del E/R:** comprobarla con la rúbrica cuando salga. **Quién:** Adrian.

---

## 5. Cumplimiento del enunciado (26/10)

«Tarea» es una tarea pendiente del [Gantt](docs/gestion/gantt.md); «corr.» es una corrección de esta lista.

| Tarea del enunciado | Estado | Qué falta |
|---|---|---|
| Necesidades, configuración y presupuesto de equipos e impresoras | Hecho, con huecos | Corr. 4 (edición de Windows de los TPV) |
| Identificar y documentar el hardware necesario | Hecho | — |
| Identificar y documentar el software necesario | Hecho, con huecos | Corr. 4 (versión de Ubuntu y del driver) |
| Instalación, optimización y monitorización de la recreativa | Parcial | Corr. 3.2; tareas 18, 51, 53 y 54 |
| Montaje y programación del arcade stick | Parcial | Tareas 19, 50 y 21 |
| Identificar necesidades de comunicación | Hecho | — |
| Implementación y configuración de sistemas operativos | Parcial | Tareas 13 y 15 |
| Restricción de cuentas y equipos (mínimos privilegios) | Parcial | Corr. 2.3; tarea 13 |
| Diseño conceptual de la web | Hecho, a posteriori | — |
| Web accesible y por HTTPS | Hecho | — |
| Hosting en AWS con dominio propio y despliegue reproducible | Casi hecho | Tarea 31 |
| ERP + TPV con un caso de uso automatizado | Hecho | Corr. 3.3; tarea 36 |
| Instalación y configuración de una impresora | Guía lista | Tareas 14 y 37 (impresora del centro) |
| Modelo E/R y tablas | Hecho | Corr. 4 (notación) |
| Implementación de la BD y consulta de sus datos | Hecho | Corr. 4 (`almi_chain` en el servidor) |
| Configurar disco redundante | Parcial | Corr. 3.1 |
| Plan de copias y prueba de restauración | Hecho, con huecos | Corr. 3.5; tarea 44 |
| Seguridad por defecto en toda la solución | Parcial | Corr. 2; tareas 24 y 46 |
| Verificar con pruebas (funcionamiento, restauración, failover) | Parcial | Corr. 3.1; tareas 13, 19-21, 24, 25 y 47 |
| Documentación reproducible con diagramas | Casi hecho | Evidencias de lo que se ejecute |
| Seguimiento (Gantt o Kanban) y Git | Hecho, con huecos | Commits de Eneko.P (tarea 5) |
| Documentación y presentación | Pendiente | Tareas 48 y 49 |

**Redes, en concreto:**

| Pide el enunciado | Estado |
|---|---|
| Contratar una línea WAN | Hecho (DIGI 1 Gb, con análisis de necesidades) |
| Esquema de conectividad | Hecho ([tarea 22, sección 4](docs/redes/22-comparativa-wan.md#4-esquema-de-conectividad)) |
| Diagrama de la red (plano), cableado y Wi-Fi | Hecho: plano y Packet Tracer de la red real probado |
| Red configurada de forma segura | Parcial: red decidida; faltan corr. 2.1 y 2.4 y la tarea 24 (invitados en el router) |
| Segundo router por WDS, comprobando que funciona | Sin empezar (tarea 25) |
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
- [ ] Restic: `ls tarea-44/.credenciales-backup` en el PC del técnico → «No existe».
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
- [ ] `660,00 €`, factura validada, cobrada y con PDF.

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
