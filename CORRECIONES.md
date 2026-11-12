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
| **Adrian** | Nada: E/R en notación Chen y VM del gerente cerrados el 30/10 (sección 1) |
| **Iker** | [2.1](#21-contraseñas) clave SSH de la recreativa · [2.3](#23-menús-del-cajero-tarea-34) menús del cajero · [2.4](#24-cortafuegos-del-servidor) cortafuegos del servidor · [4](#4-datos-que-faltan-en-tareas-hechas) `08-usuarios.sql` en el servidor |
| **Peio** | Nada en esta lista: su tarea abierta (25) está en el Gantt; la 24 se cerró el 30/10 |
| **Eneko.P** | Nada en esta lista: la 3.2 se cerró con las medidas de la tarea 54 (29/10) |
| **Markel** | Nada en esta lista: la edición de Windows de los TPV se cerró el 30/10 (sección 1) |
| **Todos** | [4](#4-datos-que-faltan-en-tareas-hechas) sus filas del registro de IA |

---

## 1. Ya corregido

| Bloque | Qué se corrigió |
|---|---|
| Seguridad | Contraseñas Wi-Fi y RADIUS tapadas en las capturas; preseed de la recreativa sin clave SSH fija y SSH sin contraseña; actualizaciones de seguridad de la recreativa a las 5:00; contraseñas robustas en la VM del gerente (tarea 55); contraseñas Wi-Fi y de administración del router cambiadas y en KeePassXC (26/10); contraseñas de Packet Tracer en KeePassXC (26/10); Drive sin ficheros de contraseñas (24/10); contraseña de restic en KeePassXC y borrada del PC del técnico (27/10); **Odoo por HTTPS** hecho y probado en VM (26/10; activarlo en el servidor del equipo es la tarea 52) |
| Redes | Tarea 22 con análisis de necesidades y esquema de conectividad; tarea 23 con cita literal, invitados en `192.168.50.0/24` y switch; **red plana con invitados aislada** decidida (24/10) y diseño antiguo con VLAN quitado (25/10); Packet Tracer de la red real con 16 de 16 pruebas ([evidencia](docs/redes/evidencias/23-red-local-configuracion-y-pruebas.txt)) |
| Hardware | Presupuesto completo; Windows 10 IoT LTSC para los TPV, **decidida y con precio: 2 × 37,41 € (licencia Entry), sumados al presupuesto (30/10)**; las VM de la tarea 13 la simulan con Windows 11 Pro porque la LTSC no se descarga sin contrato OEM; versiones del software; WAN unificada en DIGI 1 Gb |
| Arcade | **Recreativa medida en 1 núcleo y 1 GB** (`Recreativa-53`, 29/10): 3 arranques antes y 3 después de optimizar y 10 min de juego, con 967 MB de RAM en las medidas ([tarea 54](docs/arcade/54-medidas-equipo-real/DOCUMENTACION.md)) |
| Arduino | Firmware con palanca digital y botones 7-8; esquema con la palanca en A2-A5 |
| ERP | Caso de uso de la tarea 35 al 10 %; TicketBAI decidido; 2 fallos de los scripts de Odoo que impedían instalar en limpio; **factura de la tarea 35 repetida con el menú de grupo: `INV/2026/00004` = 660,00 €**, y el script fija el IVA en la línea y comprueba el total (Iker, 27/10); la errónea `INV/2026/00003` anulada con la rectificativa `RINV/2026/00001` ([evidencia](docs/erp/35-factura-automatica/evidencias/rectificativa-INV00003.txt)) |
| BD | Datos, consultas y usuarios de `almi_chain` ejecutados con evidencias ([41](docs/bd/evidencias/41-datos-y-consultas.txt), [42](docs/bd/evidencias/42-usuarios-y-permisos.txt)); **E/R en notación Chen** (30/10, [tarea 38, sección 2](docs/bd/38-modelo-er.md#2-diagrama)), con el `.drawio` y el SVG generados por `scripts/bd/er-chen.py` |
| Copias | Procedimiento para la BD en el RAID; aviso del USB; RTO real marcado como pendiente; **BD de Odoo en el RAID** y fallo repetido con Odoo funcionando: con un disco quitado se guarda la venta `S00007`, el espejo vuelve a `[UU]` y tras reiniciar Odoo responde (Iker, 27/10, [evidencias 10-12](docs/backup/43-raid1/evidencias/)) |
| Web | CSP y Permissions-Policy; distancia al local; créditos; contraste, favicon y W3C; evidencias repetidas contra la versión publicada y Lighthouse móvil de 70 a 94 cargando el mapa al pulsar (26/10) |
| SO | **Las VM no van a Drive** (decisión del 30/10): cada una se queda en el PC de quien la tiene, con su lista en [maquinas-virtuales.md](docs/gestion/maquinas-virtuales.md); la del gerente, en el de Adrian con la instantánea del 29/10 |
| Gestión | Fechas reales; responsables coherentes; Anexo II con requisitos separados; decisiones del equipo apuntadas; 14 enlaces rotos |

---

## 2. Seguridad

### 2.1 Contraseñas

- [ ] 🟢 **Recreativas instaladas con el preseed antiguo:** borrar la línea `recreativa-claude` de `~tecnico/.ssh/authorized_keys`.
  - **Quién:** Iker.

Lo demás de este apartado está corregido (sección 1). Limitar la administración del router a la MAC del gerente y apagar WPS se hizo en la tarea 24 (29/10).

### 2.2 HTTPS en Odoo (tarea 52)

Corregido el 26/10 (sección 1). Activarlo en la `ServidorERP` del equipo es trabajo de la tarea 52 ([runbook](docs/erp/52-https-odoo/RUNBOOK.md)), en el Gantt.

### 2.3 Menús del cajero (tarea 34)

- [ ] 🟠 **El cajero ve más aplicaciones de las que necesita** (la tarea 34 está en Hecho). ✅ **Probado en el laboratorio (30/10); falta en el servidor del equipo.** `restringir-menus-cajero.py`; entrar como `cajero1` y hacer la captura nueva (solo ve Punto de venta).
  - **Quién:** Iker.
  - 26/10: en la VM de la tarea 52, `cajero1` entra directo en *Punto de venta* por HTTPS ([evidencia 08](docs/erp/52-https-odoo/evidencias/08-tpv-cajero1-https.png)), pero la captura no enseña el menú de aplicaciones, que es lo que hay que demostrar. 27/10: añadido al [runbook de la 52](docs/erp/52-https-odoo/RUNBOOK.md#31-menús-del-cajero-corrección-23) (paso 3.1), con la contraseña leída del `.env` y las dos capturas que faltan. 30/10 (Adrian): probado en la `ServidorERP` de laboratorio, y **el script tenía un fallo**: añadía el grupo de gerencia a los menús, pero Odoo los enseña si el usuario está en cualquiera de sus grupos, así que el cajero seguía viendo Contactos, Empleados, Conversaciones, Calendario y Aplicaciones. Arreglado (deja gerencia como único grupo y guarda los originales para `--deshacer`) y comprobado con el nuevo `ver-menus-usuarios.py`: el cajero ve solo *Punto de venta* ([evidencia](docs/erp/34-configurar-odoo/evidencias/23-menus-cajero-laboratorio.txt)). Solo falta lanzar las dos órdenes del paso 3.1 en el servidor del equipo.

### 2.4 Cortafuegos del servidor

- [ ] 🟠 ✅ **Probado en el laboratorio (30/10); falta en el servidor del equipo.** **La red plana solo es segura si cada equipo filtra** ([tarea 23, 5.3](docs/redes/23-plano-direccionamiento.md#5-segmentación)), y el servidor aún no lo hace: `sudo docs/erp/33-odoo-docker/cortafuegos-servidor.sh` en `ServidorERP` y guardar `ufw status verbose`.
  - **Quién:** Iker.
  - 30/10 (Adrian): probado en la `ServidorERP` de laboratorio ([evidencia](docs/erp/33-odoo-docker/evidencias/24-cortafuegos-laboratorio.txt)); Odoo sigue respondiendo. **El script tenía un fallo**: lanzado como `ssh servidor 'sudo …'` no detectaba la IP de la conexión (sudo borra `SSH_CLIENT` y sin shell de login no hay entrada en `who`) y dejaba fuera a quien lo ejecutaba. Arreglado: la busca en los procesos padre. Lanzado así en el servidor del equipo, ahora avisa con `AVISO: también se permite SSH desde …`.

---

## 3. Pruebas que no demuestran lo que dicen

### 3.1 La BD no está en el RAID (tarea 43)

Corregido el 27/10 (sección 1).

### 3.2 Recreativa medida en una VM que no es la del enunciado (tarea 17)

Corregido el 29/10 con la tarea 54 (sección 1).

### 3.3 Factura automática con el caso de uso antiguo (tarea 35)

Corregido el 27/10 (sección 1), también la rectificativa de `INV/2026/00003`.

### 3.4 Evidencias de la web (tarea 30)

Corregido el 26/10 (sección 1).

### 3.5 RTO medido en el mismo servidor (tarea 45)

- [x] 🟠 **Los 46 s de restauración son en un entorno aislado del mismo servidor**, no en una máquina nueva: no es el RTO real. ✅ **Corregido el 10/11** (Adrian): recuperación desde cero en una VM vacía con el preseed y `recuperar-servidor-nuevo.sh`, **RTO ≈ 14 min** ([tarea 45, sección 6](docs/backup/45-restauracion/DOCUMENTACION.md), [log](docs/backup/45-restauracion/evidencias/rto-maquina-nueva-2026-11-10.log)). Sin probar desde un TPV.
  - **Quién:** Iker.

---

## 4. Datos que faltan en tareas hechas

- [x] 🟠 **Edición de Windows de los TPV:** **IoT Enterprise LTSC 2021**, a 37,41 € por TPV (licencia Entry, la del N100), en las tareas 9 y 10; el presupuesto pasa a 2.522,16 € (3.889,56 € completo y 4.249,56 € el primer año). Las VM de la tarea 13 llevan Windows 11 Pro y **simulan** la edición elegida: el presupuesto es el de la instalación real y el bastionado se configura igual en las dos (30/10, [tarea 10, 4.1](docs/hardware/10-presupuesto-hardware.md#41-equipos-tpv)). **Quién:** Markel. (El driver de Epson ya no se apunta: las pruebas se hacen con la Samsung ML-1660, decisión del 27/10.)
- [x] 🟠 **VM del gerente (tarea 12):** actualizaciones, BitLocker y cifrado de `/home/gerente` hechos el 29/10. No se exporta a Drive (decisión del 30/10): se queda en el PC de Adrian ([maquinas-virtuales.md](docs/gestion/maquinas-virtuales.md)). **Quién:** Adrian.
  - [x] Windows Update al día (KB5066791), BitLocker en `C:` con contraseña de arranque y `/home/gerente` cifrado con fscrypt (29/10, [tarea 12, sección 6](docs/so/12-dual-boot.md#6-verificación)).
  - [x] Versión de Ubuntu: **26.04.1 LTS**, imagen del 26/08/2026, leída del disco de la VM sin arrancarla y puesta en las tareas 12 y 9 (27/10, [evidencia](docs/evidencias/12-dual-boot/ubu-08-version-desde-disco.txt)).
- [ ] 🟠 **`almi_chain` en el servidor (tareas 40-42):** ✅ **base y copia hechas por Iker el 27/10** en la `ServidorERP` del equipo: 14 tablas con datos, y la copia diaria lleva `almi_chain.dump` junto a la de Odoo ([evidencia 04 de la tarea 44](docs/backup/44-backup-3-2-1/evidencias/04-almi-chain-y-aviso-de-fallo.log)). **Solo falta** cargar `08-usuarios.sql` con las contraseñas de KeePassXC (no sale en esa evidencia) y guardar la salida. **Quién:** Iker.
  - 04/11 (Adrian): hecho en la `ServidorERP` de laboratorio: `almi_chain` cargada, volcada por `backup-odoo` al RAID, al USB y a S3, y restaurada desde el RAID y desde S3 con sus tablas, filas, importes y permisos comparados (23 OK, [tarea 45](docs/backup/45-restauracion/DOCUMENTACION.md)). Los mismos comandos sirven en el servidor del equipo.
- [ ] 🟠 **Registro de IA:** cada persona pone en sus filas qué comprobó a mano, en vez de «pendiente de revisar por el equipo». **Quién:** todos.
- [x] 🟢 **Imágenes de la web:** copiadas a `web/img/` en WebP, con su autor en los créditos y en `web/img/CREDITOS.txt`; la txuleta del carrusel ya no repite la portada (que eran costillas) y la tarta de queso es otra foto de autor conocido. La CSP del servidor deja de admitir `images.unsplash.com` (se aplica al reinstalar). Adrian, 27/10. Publicado ese día con `desplegar-web` (secretos del Learner Lab renovados): el `index.html` público es idéntico al del repositorio (8425 bytes) y `img/txuleta-640.webp` se sirve desde la propia web.
- [x] 🟢 **Notación del E/R:** pasado a **Chen**, la de clase (30/10, [tarea 38](docs/bd/38-modelo-er.md#21-notación-chen)). Si la rúbrica pide otra, se cambia en `scripts/bd/er-chen.py`. **Quién:** Adrian.

---

## 5. Cumplimiento del enunciado (10/11)

«Tarea» es una tarea pendiente del [Gantt](docs/gestion/gantt.md); «corr.» es una corrección de esta lista.

| Tarea del enunciado | Estado | Qué falta |
|---|---|---|
| Necesidades, configuración y presupuesto de equipos e impresoras | Hecho: Windows de los TPV decidido y con precio (30/10) | — |
| Identificar y documentar el hardware necesario | Hecho | — |
| Identificar y documentar el software necesario | Hecho (Ubuntu 26.04.1 LTS leído del disco; el driver de Epson no se apunta, decisión del 27/10) | — |
| Instalación, optimización y monitorización de la recreativa | Hecho: Debian + MAME en la VM de 1 núcleo y 1 GB (tarea 53) y medidas antes y después (tarea 54, 29/10) | Tarea 62: justificar el front-end |
| Montaje y programación del arcade stick | Hecho: montado y probado en la placa, con la EEPROM, en MAME (tarea 53) y en Batocera (27-29/10); antirrebote en el firmware (04/11) y probado en la placa (12/11); componentes con precio y por qué la Leonardo (tarea 59) | — |
| Identificar necesidades de comunicación | Hecho | — |
| Implementación y configuración de sistemas operativos | Hecho: TPV bastionados (tarea 13) y PC del gerente con contraseñas robustas (tarea 55) y servicios reducidos (tarea 64, 09/11) | Tarea 15: ejecutar `configurar-tpv.ps1` en los TPV |
| Restricción de cuentas y equipos (mínimos privilegios) | Hecho en el laboratorio: cajero solo con Punto de venta (30/10) | Corr. 2.3 en el servidor del equipo; tarea 15 |
| Diseño conceptual de la web | Hecho, a posteriori | 10/11 (tarea 62): wireframe y punto de corte de tableta, WCAG 2.1 AA criterio a criterio y patrones de UX ([tarea 27](docs/web/27-wireframes.md)) |
| Web accesible y por HTTPS | Hecho | — |
| Hosting en AWS con dominio propio y despliegue reproducible | Hecho: Terraform aplicado y despliegue por GitHub Actions (tarea 31, 29/10) | — |
| ERP + TPV con un caso de uso automatizado | Hecho: factura de 660,00 € (27/10); importar y exportar con ida y vuelta (tarea 36, 12/11) y módulos usados con datos (tarea 63, 12/11) | Dar a `gerente` «Permitir exportar» en el servidor del equipo (tarea 36, sección 3.3) |
| Instalación y configuración de una impresora | Hecho: ticket de Odoo impreso desde el TPV (Samsung por IPP, tarea 37, 27/10) | — |
| Modelo E/R y tablas | Hecho: E/R en notación Chen (30/10), con relación ternaria, historial de precios y atributos especiales (tarea 56, 04/11) | Tarea 57: enlazar `almi_chain` con Odoo |
| Implementación de la BD y consulta de sus datos | Hecho: `almi_chain` en el servidor del equipo y en su copia (27/10) | Cargar `08-usuarios.sql` en el servidor (corr. 4) |
| Configurar disco redundante | Hecho: BD de Odoo en el RAID 1 y fallo probado con Odoo funcionando (27/10) | — |
| Plan de copias y prueba de restauración | Hecho: copia en el RAID, el USB y S3 (04/11), restauración comprobada desde el RAID y desde S3 y RTO real de 14 min en una VM nueva (10/11) | — |
| Seguridad por defecto en toda la solución | Hecho (tarea 46, cerrada el 12/11): revisión transversal con el preseed endurecido (04/11); sin las comprobaciones 2 y 3 en los equipos del equipo | Corr. 2.1 y 2.4 en el servidor del equipo; tarea 46 |
| Verificar con pruebas (funcionamiento, restauración, failover) | Casi hecho: failover del RAID y restauración probados; [tabla de pruebas](docs/gestion/47-tabla-pruebas.md) repasada fila a fila (tarea 47, 10/11) | Tareas 15, 25 y 59 (las filas ⏳ de la tabla) |
| Documentación reproducible con diagramas | Hecho: [LOGICA_RETO](LOGICA_RETO.md) al día con el montaje desde cero en orden (sección 15) y el capítulo de restauración (tarea 48, 10/11) | — |
| Seguimiento (Gantt o Kanban) y Git | Hecho, con huecos | Commits de Eneko.P (tarea 5) |
| Documentación y presentación | Documentación hecha; presentación en curso | Tarea 49 |

**Redes, en concreto:**

| Pide el enunciado | Estado |
|---|---|
| Contratar una línea WAN | Hecho (DIGI 1 Gb, con análisis de necesidades) |
| Esquema de conectividad | Hecho ([tarea 22, sección 4](docs/redes/22-comparativa-wan.md#4-esquema-de-conectividad)) |
| Diagrama de la red (plano), cableado y Wi-Fi | Hecho: plano y Packet Tracer de la red real probado |
| Red configurada de forma segura | Casi hecho: tarea 24 hecha (30/10): red de invitados aislada y probada, WPS desactivado, administración solo desde la MAC del gerente y contraseñas en KeePassXC. WPA3 queda como limitación del TL-WR841N. Falta corr. 2.4 en el servidor del equipo y desactivar UPnP en el router (A-22) |
| Segundo router por WDS, comprobando que funciona | Hecho (tarea 25, cerrada el 12/11 sin las mejoras de la sección 7): el 04/11 el router 2 extiende la red del proyecto en `192.168.10.2` sin DHCP, con ping al router 1 y los invitados sin acceso a la LAN. Falta enlazarlo a la Wi-Fi de clientes (en Range Extender repite una sola red y hoy es la del personal), la prueba en el BSSID del router 2 y la cobertura antes y después: hoja de trabajo en la tarea 25, sección 7 |
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
- [x] `cat /proc/mdstat` → `[UU]` (27/10, evidencia 12 de la tarea 43).
- [ ] `sudo docker info` → *Docker Root Dir* es `/srv/datos/docker`, y en `sudo docker volume inspect odoo_odoo-db-data` el *Mountpoint* está dentro de `/srv/datos`.
- [x] Tras `sudo reboot`, Odoo vuelve solo (Docker arranca después de montar el RAID) (27/10, evidencia 12).
- [x] Con un disco del RAID quitado, una venta se guarda; tras reconstruir, `[UU]` otra vez y la venta sigue ahí (27/10, `S00007`, evidencia 11).
- [ ] `sudo restic -r /srv/datos/restic ls latest | grep -E "tienda.dump|almi_chain.dump"` → salen los dos volcados.
- [ ] RTO real: está el tiempo cronometrado de una restauración en una **VM nueva**, y aparece en la tarea 45, LOGICA_RETO y el Anexo II.

**Recreativa (3.2)**
- [x] La evidencia muestra que la VM es de **1 núcleo y 1 GB**: `nproc` → 1 y `free -m` → 967 MB ([tarea 53, 06-comprobaciones](docs/arcade/53-recreativa-fisica/evidencias/06-comprobaciones.txt)), y `mem_total_mb` = 967 en las medidas de antes y de después ([monitor_antes](docs/arcade/54-medidas-equipo-real/evidencias/monitor_antes_20261029-130134.csv), [monitor_despues](docs/arcade/54-medidas-equipo-real/evidencias/monitor_despues_20261029-132504.csv)) (29/10).

**Factura automática (3.3)**
- [x] `660,00 €`, factura validada, cobrada y con PDF (`INV/2026/00004`, 27/10).

**Web (3.4 y 4)**
- [x] `curl -sI https://almichain1.duckdns.org | grep -i content-length` da el mismo número que `wc -c < web/index.html`. (26/10)
- [x] `curl -sI https://almichain1.duckdns.org` incluye `content-security-policy` y `permissions-policy`. (26/10)
- [x] La web carga **sin errores en la consola** del navegador (la CSP no bloquea las fotos ni el mapa). (26/10)
- [x] Lighthouse **contra la URL pública**: 90 o más en las cuatro categorías; W3C sin errores (26/10: móvil 94/100/100/100, escritorio 99/100/100/100).

**VM del gerente (4)**
- [x] `lsb_release -d` en la tarea 12; historial de Windows Update con una actualización acumulativa; `manage-bde -status` con `C:` cifrada. (29/10)

### 6.3 Antes de entregar

- [ ] `bash scripts/verificar-repo.sh` **con Docker** (incluye shellcheck, W3C y **gitleaks de todo el historial**) → «Todo correcto».
- [ ] Ninguna tarea en **Hecho** sin evidencia: `python3 scripts/gantt.py` no da errores y cada evidencia se abre.
- [ ] `git grep -n -i "pendiente" -- docs LOGICA_RETO.md`: cada «pendiente» que quede es real y está en esta lista o en el Gantt.
- [ ] Todas las capturas del repositorio revisadas ampliadas, una a una, buscando contraseñas, tokens, IP públicas propias o datos personales.
- [ ] README (número de tareas hechas), LOGICA_RETO y Anexo II dicen lo mismo que el CSV.
- [ ] Cada persona del equipo sabe explicar el NAT, la red de invitados, el WDS, el porqué de la red plana (tarea 23, apartado 5.3) y cómo se recupera una copia.
