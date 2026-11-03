# Tarea 46: Revisión de seguridad transversal

- **Bloque:** 10 Seguridad
- **Responsable:** Adrian
- **Depende de:** tareas 13, 24, 30, 42 y 52
- **Estado (03/11/2026):** 🟡 Revisión del repositorio hecha el 26/10 y repasada el 27/10, el 29/10 y el 03/11 con lo que entró después (secciones 1.1 a 1.3): 26 hallazgos; 10 corregidos (S-01, S-04, S-05, S-06, S-13, S-15, S-18, S-21, S-22 y S-24), S-11 hecho en el PC del gerente, S-12 resuelto en el diseño de los TPV y S-03 ya no aplica. Comprobaciones de la sección 5: 1, 4, 5 y 9 hechas; 2, 3, 6 y 7 en el laboratorio (6 y 7 confirman S-08 y S-09). Faltan las de los equipos del equipo en la red y que cada responsable cierre los suyos (sección 3).

## 1. Qué se ha revisado y cómo

El enunciado pide que todo el sistema esté «configurado de forma segura». Cada tarea ha cuidado su parte. Esta revisión mira el conjunto, porque un fallo en una pieza puede anular las medidas de otra (por ejemplo, una CA mal limitada en el servidor anula el bastionado de los TPV).

| Área | Qué se ha leído | Tareas |
|---|---|---|
| Servidor ERP | `preseed-servidor.cfg`, `desplegar-odoo.sh`, `docker-compose.yml`, `cortafuegos-servidor.sh`, `odoo.conf` generado | 33, 34 |
| Proxy HTTPS | `activar-https.sh`, `nginx.conf`, `docker-compose.https.yml` y sus 15 pruebas | 52 |
| TPV | `configurar-tpv.ps1`, `comprobar-tpv.ps1` | 13, 15 |
| PC del gerente | Documentación y evidencias del arranque dual y de las contraseñas | 12, 55 |
| Red | Plano, segmentación y configuración del router | 23, 24 |
| Base de datos | `03-roles.sql`, `08-usuarios.sql` y sus evidencias | 40, 42 |
| Copias | `instalar-backup.sh`, `backup-odoo.sh` | 44, 45 |
| Recreativa | Preseed de Debian, `instalar-arcade.sh` y notas de Batocera | 16, 17 |
| Web en AWS | `iac/*.tf`, `user-data.sh.tftpl`, `instalar-servidor-web.sh`, `desplegar-web.yml` | 30, 31 |
| Repositorio | `.gitignore`, gitleaks, búsqueda de contraseñas en scripts, historial de las capturas | 5 |

**Método.** Se leen los scripts y configuraciones tal como están en `main`, porque son lo que se ejecuta en los equipos. Cada hallazgo se clasifica así:

- **Alta:** permite a alguien de dentro o de la Wi-Fi leer contraseñas o ventas, o tomar el control de un equipo.
- **Media:** debilita una de las capas de defensa, aunque haya otra que lo frena.
- **Baja:** mejora recomendable con poco impacto.

Lo que no se puede ver en el repositorio (la configuración real del router, los equipos encendidos) queda en la sección 5 como comprobación manual.

### 1.1 Repaso del 27/10/2026

Se leyó lo que entró en `main` después de la revisión (PR #57 a #65):

| Qué | Resultado |
|---|---|
| Tarea 13 hecha a mano por Markel ([guía](../../so/13-tpv/Tarea13_Markdown_GitHub/13-bastionado-tpv-windows.md)) | Hallazgo nuevo **S-20**: los TPV no tienen todo lo que da `configurar-tpv.ps1`. Corregida la sección 6, que lo daba por hecho |
| Tarea 51 (Debian + MAME; `optimizar-batocera.sh`) | Se descarta Batocera: **S-03 ya no aplica**. El script, por si se usara, activa la seguridad y no guarda la contraseña |
| Stick (`mando_joystick.ino`, `subir.sh`) | Firmware bien: comandos con límites, búfer acotado y la EEPROM se valida (firma, versión, suma y rango). Hallazgo nuevo **S-21** en `subir.sh`, corregido |
| Tarea 52 (`fijar-url-y-qr.sh`, impresión por IPP) | Sin hallazgos. El script lee `/opt/odoo/.env` como root y no muestra la contraseña. El CUPS compartido es solo del laboratorio del PC de Adrian, no del proyecto |

### 1.2 Repaso del 29/10/2026

Se leyó lo que entró en `main` del PR #66 al #84 (scripts y configuraciones):

| Qué | Resultado |
|---|---|
| Tarea 12: BitLocker y fscrypt (`scripts/so/`) | Sin hallazgos. La clave de recuperación no sale por pantalla (`-WarningAction`); al crearla la primera vez sí salió y se sustituyó (tarea 12, sección 7). **S-11** hecho en el PC del gerente; **S-12** cambia: el gerente ya tiene la última acumulativa, pero Windows 10 sigue sin soporte |
| Tarea 42: `08-usuarios.sql` | Hallazgo nuevo **S-22**, corregido |
| Tarea 44: aviso de fallo y copia en S3 | `aviso-fallo-backup.sh` correcto (fichero de estado 700, `/etc/default/backup-odoo` de root). Hallazgo nuevo **S-23** en la copia a S3 |
| Tarea 53: `preparar-preseed-fisico.sh` | Bien: contraseña con `read -rs`, solo el hash SHA-512 en el preseed, fichero 600 y fuera de Git, disco y clave SSH validados |
| Tarea 26: `analizar-red.sh` | Sin hallazgos (solo lee con nmap y avisa de escanear solo la red del reto) |
| Tarea 43 | La BD ya está en el RAID (27/10): **S-02** deja de esperar a la 43 |

### 1.3 Repaso del 03/11/2026

Se leyó lo que entró en `main` del PR #85 al #99 y se hicieron las comprobaciones de la sección 5 que no necesitan la red física:

| Qué | Resultado |
|---|---|
| Tarea 26: nmap y Wireshark con el router real (30/10, Eneko.S) | **Comprobación 1 hecha:** desde la Wi-Fi de invitados no se ve ningún equipo de la LAN y el panel y el SSH del router salen filtrados. Cierra S-13 y confirma S-06. Sus hallazgos H-01 (UPnP) y H-02 (SSH y firmware antiguos del router) pasan aquí como **S-25** |
| Corrección 2.4: `cortafuegos-servidor.sh` | Bien: busca `SSH_CLIENT` en los procesos padre para no dejar fuera a quien lo lanza por `ssh host 'sudo …'`, y avisa de quitar esa regla al acabar. Probado en el laboratorio (tarea 33, evidencia 24) |
| Corrección 2.3: `restringir-menus-cajero.py` y `ver-menus-usuarios.py` | Bien: el grupo de gerencia queda como único grupo de los menús (antes se sumaba a «Usuario interno» y no ocultaba nada) y se puede deshacer. `ver-menus-usuarios.py` lee las contraseñas de `/root/.credenciales-usuarios`, que sigue en el servidor: hallazgo nuevo **S-26** |
| Tareas 9 y 10: Windows de los TPV | Decidida la **LTSC 2021** (30/10), con soporte hasta 2032: **S-12** queda resuelto en el diseño para los TPV |
| Tarea 50: `probar-stick.py` | Sin hallazgos (solo lee el mando) |
| Comprobaciones 2, 6 y 7 en la `ServidorERP` del laboratorio | Hacia fuera solo escuchan 22, 80 y 443. El SSH sigue aceptando contraseña (S-08) y no está `unattended-upgrades` (S-09): los dos siguen abiertos ([evidencia 02](evidencias/02-servidor-laboratorio-puertos-ssh.txt)) |

## 2. Resumen

| Gravedad | Hallazgos | Corregidos |
|---|---|---|
| Alta | 6 (S-01 a S-05 y S-24) | 4 (S-01, S-04, S-05 y S-24); S-03 no aplica |
| Media | 10 (S-06 a S-12, S-20, S-23 y S-25) | 1 (S-06, 30/10); S-11 hecho en el PC del gerente (faltan los TPV); S-12 resuelto en el diseño de los TPV |
| Baja | 10 (S-13 a S-19, S-21, S-22 y S-26) | 5 (S-13, S-15, S-18, S-21 y S-22) |

Lo más urgente, por este orden:

1. ~~**Router:** red de invitados sin hacer, y administración abierta a toda la LAN y WPS (S-06, S-04).~~ Hecho: S-04 el 29/10 y S-06 el 30/10 (tarea 24).
2. **Odoo sigue por HTTP en la LAN** hasta activar la tarea 52 en el servidor del equipo (S-02).
3. **Los TPV reales no tienen el bastionado completo** (S-20): sin bloqueo de salida en el firewall ni lista blanca en Edge.
4. **SSH con contraseña y sin actualizaciones automáticas en el servidor** (S-08, S-09): comprobado el 03/11 en el laboratorio; los comandos de la sección 4.2 lo arreglan.

## 3. Hallazgos

| ID | Gravedad | Dónde | Qué pasa | Qué hacer | Responsable | Estado |
|---|---|---|---|---|---|---|
| S-01 | Alta | Tarea 52, `activar-https.sh` | El certificado de Odoo es una CA (`CA:TRUE`) sin límites, y se instala como raíz de confianza en los TPV y en el PC del gerente. Quien robara `odoo.key` del servidor podría firmar certificados de **cualquier** web (banco, correo) y los TPV se los creerían | Añadir `nameConstraints` para que solo valga para `192.168.10.10` y `odoo.almichain.local` | Adrian | ✅ Corregido en el script y probado en la VM de la tarea 52, también en Edge (candado sin avisos) (sección 4.1). Se aplica al generar el certificado en el servidor del equipo |
| S-02 | Alta | Tareas 33 y 52 | Odoo va por **HTTP** en la LAN: contraseñas de cajeros y del gerente y ventas sin cifrar | Activar el proxy en la `ServidorERP` del equipo e instalar el `.crt` en los TPV | Adrian | ⏳ Probado entero en VM, con TPV provisional y venta sin red (tarea 52, sección 4.2). Falta en el servidor del equipo: ya no espera a nada (la tarea 43 llevó la BD al RAID el 27/10), es seguir el [runbook](../../erp/52-https-odoo/RUNBOOK.md) |
| S-03 | Alta | Tarea 16, Batocera | Con *Enforce security* desactivado, root tiene siempre la contraseña `linux`, se ve en el menú y sirve también para SSH y Samba | `batocera-settings-set system.security.enabled 1` y contraseña de root aleatoria en KeePassXC. O quedarse con la versión Debian, que ya está endurecida (S-08 lo compara) | Iker | ➖ No aplica: la tarea 51 elige Debian, ya endurecida (27/10) |
| S-04 | Alta | Tarea 24, router | Se entra al panel como `Admin` con una contraseña de 5 caracteres que parece la de fábrica. El panel va por HTTP y está abierto a toda la LAN. No hay evidencia de que WPS esté apagado | Contraseña de KeePassXC, administración solo desde la MAC del gerente y por cable, y WPS desactivado | Peio | ✅ Contraseña cambiada (26/10), administración solo desde la MAC del PC del gerente y WPS desactivado (29/10, tarea 24). El PIN de WPS se leía en una captura: ver S-24 |
| S-05 | Alta | Tarea 24, Wi-Fi | La contraseña Wi-Fi tiene 8 cifras y se leía en dos capturas que siguen en el historial de Git (commits `532c87a` y `215eac7`). El repositorio es privado, lo que lo atenúa, pero el profesor y cualquiera con acceso las pueden ver | Cambiarla por una frase de 20 caracteres o más. No hace falta reescribir el historial si se cambia la contraseña | Peio | ✅ Cambiada y en KeePassXC (26/10). Comprobar que la RADIUS de las mismas capturas tampoco sigue en uso |
| S-06 | Media | Tareas 23 y 24 | La red de invitados no está configurada. La tabla 5.2 de la tarea 23 confía en ella para que clientes y recreativa no lleguen al servidor ni a los TPV | Red `192.168.50.0/24` sin acceso a la LAN y con aislamiento entre clientes; pruebas 3 a 5 de la tarea 23 | Peio | ✅ Red de invitados configurada el 29/10 (sin acceso a la LAN, aislamiento entre clientes). 30/10: desde invitados, ping sin respuesta al PC del gerente y a otro invitado (tarea 24, P3b y P4). Sigue en la misma subred `192.168.10.0/24`: el TL-WR841N no le da una propia |
| S-07 | Media | Tarea 24 | El TL-WR841N no tiene WPA3. Queda WPA2-AES, con la clave de grupo sin renovar (`0`) y modo `11bgn` | WPA3 (o WPA2/WPA3) en el Archer C6, renovación de la clave de grupo cada 3600 s y sin 802.11b. Si no se compra, dejarlo como limitación | Peio | 🟡 Clave de grupo renovada cada 3600 s (29/10, tarea 24). WPA3 queda como limitación del TL-WR841N; el Archer C6 no se ha comprado |
| S-08 | Media | Tarea 33, `preseed-servidor.cfg` | El SSH del servidor admite contraseña (el preseed de la recreativa sí lo cierra y el del servidor no). Además, la única clave autorizada es la del laboratorio (`recreativa-claude`), no la del PC del gerente | Ver sección 4.2 | Iker | ⏳ Pendiente. 03/11: comprobado en el laboratorio, el servidor sigue ofreciendo contraseña (comprobación 6) |
| S-09 | Media | Tareas 33 y 52 | El servidor no tiene `unattended-upgrades` (el preseed no lo instala y Debian sin escritorio no lo trae). Las imágenes `odoo:19.0`, `postgres:17` y `nginx:1.27-alpine` no tienen un procedimiento de actualización | Ver sección 4.2 | Iker | ⏳ Pendiente. 03/11: en el laboratorio no está instalado (comprobación 7) |
| S-10 | Media | Tarea 33, `docker-compose.yml` | Odoo se conecta a PostgreSQL con el usuario de `POSTGRES_USER`, que la imagen de PostgreSQL crea como **superusuario**. Choca con los mínimos privilegios de la tarea 42. Lo atenúa que PostgreSQL no está publicado fuera de Docker | Mejora para un despliegue nuevo: un rol `odoo` con `CREATEDB` y sin `SUPERUSER`. Hoy se acepta y se documenta, porque cambiarlo con datos reales tiene riesgo | Iker | Aceptado (riesgo documentado) |
| S-11 | Media | Tareas 12 y 13 | Ni el PC del gerente (BitLocker desactivado para el arranque dual, Ubuntu sin LUKS) ni los TPV tienen el disco cifrado. Si roban el equipo, se leen los datos sin contraseña | BitLocker en Windows y cifrado de `/home/gerente` (tarea 12, sección 4.4). BitLocker en los TPV (Pro e IoT Enterprise lo incluyen) | Adrian (12), Markel (13) | ◐ Gerente hecho el 29/10 (BitLocker + fscrypt); TPV pendiente |
| S-12 | Media | Tareas 12 y 13 | Windows 10 dejó de tener soporte el 14/10/2025. Sin ESU o LTSC, el PC del gerente y los TPV no reciben parches. El 29/10 la VM del gerente recibió la última acumulativa gratuita (2025-10, KB5066791): a partir de ahí ya no llega nada | TPV: IoT Enterprise LTSC 2021 (soporte hasta 2032), decisión pendiente en la tarea 13. Gerente: ESU, o usar Ubuntu para el trabajo diario y dejar Windows solo para lo imprescindible | Markel, Adrian | ⏳ Gerente: al día hasta octubre de 2025 (tarea 12); la decisión (Windows 11 Pro o ESU) queda para el equipo real. TPV: decidida la LTSC 2021 el 30/10 (tareas 9 y 10), con soporte hasta 2032 |
| S-13 | Baja | Tarea 52 y Docker | `ufw` no filtra los puertos que publica Docker: la regla «80/443 solo desde la LAN» de `cortafuegos-servidor.sh` no se aplica al proxy. Con la red de invitados aislada (S-06) no hay ruta hasta él, así que el impacto es bajo | Comprobarlo con nmap desde la red de invitados (sección 5). Si llega, regla en la cadena `DOCKER-USER` | Adrian | ✅ Comprobado el 30/10 (tarea 26): desde invitados no se ve ningún equipo de la LAN, así que no hay ruta al proxy. No hace falta la regla |
| S-14 | Baja | Tareas 13 y 52 | `configurar-tpv.ps1` permite por defecto los puertos 8069 y 443. Con el proxy activo, el TPV podría seguir abriendo `http://…:8069` (el servidor lo tiene cerrado, pero no es la configuración mínima) | Volver a ejecutarlo con `-PuertosOdoo 443` después de activar HTTPS (lo hace el runbook de la tarea 52) | Markel | ⏳ Con la tarea 52 |
| S-15 | Baja | Tareas 34 a 36 | Los scripts se lanzan con `ODOO_PASSWORD=... python3 …`. La contraseña queda en `~/.bash_history` | `read -rs ODOO_PASSWORD && export ODOO_PASSWORD` antes de ejecutarlos. Cambiarlo en los ejemplos de uso | Iker, Eneko.P | ✅ Corregido el 27/10: los ejemplos de uso de los scripts de las tareas 34 a 36 piden la contraseña con `read -rs` (no se ve ni queda en el historial) |
| S-16 | Baja | Tarea 31, `user-data.sh.tftpl` | El token de DuckDNS va en el `user_data`. Lo puede leer cualquier proceso de la EC2 (IMDS) y queda en claro en `terraform.tfstate`. `.gitignore` excluye el `tfstate`, así que no llega al repositorio | Aceptable en el laboratorio. En producción: guardarlo en SSM Parameter Store y leerlo desde la instancia | Eneko.P | Aceptado |
| S-17 | Baja | Tarea 30 | `LabInstanceProfile` tiene más permisos de los que necesita la EC2 (solo leer un bucket). Ya está documentado como limitación del Learner Lab | Nada en el laboratorio. En producción, un rol con `s3:GetObject` y `s3:ListBucket` | Adrian | Aceptado (limitación) |
| S-18 | Baja | `.github/workflows/` | Las acciones se referencian por etiqueta (`actions/checkout@v4`), no por SHA. Si alguien moviera la etiqueta, se ejecutaría otro código con los secretos de AWS | Fijarlas por SHA en `desplegar-web.yml`, que es el que usa secretos | Eneko.P | ✅ Corregido el 27/10: las acciones de los dos flujos van fijadas por SHA, en las mismas versiones (checkout v4.4.0, setup-terraform v3.1.2, gitleaks-action v2.3.9) |
| S-19 | Baja | Tareas 34 y 52, ticket del TPV | El QR «¿Necesita una factura?» del ticket apunta a la IP vieja del servidor (`web.base.url` no se actualiza). Aunque apuntara bien, el cliente está en la Wi-Fi de invitados, que no llega al servidor: el QR invita a una dirección interna que no le sirve | [`fijar-url-y-qr.sh`](../../erp/52-https-odoo/fijar-url-y-qr.sh): fija `web.base.url` y `web.base.url.freeze` y quita el QR del recibo | Adrian | 🟡 Probado en la VM (el ticket sale sin QR con una sesión de caja nueva). Falta en el servidor del equipo, paso 2.1 del runbook de la 52 |
| S-20 | Media | Tarea 13, TPV hechos a mano | Los TPV se configuraron a mano, no con `configurar-tpv.ps1`. Tienen usuario estándar, quiosco, USB bloqueado, firewall y Defender, pero el firewall solo está «activado» (por defecto Windows deja salir todo), no consta que la UAC deniegue la elevación ni que Edge tenga lista blanca y descargas bloqueadas, y el quiosco apunta a `http://localhost:8069`. Un cajero podría navegar a otras webs o sacar datos por la red | Ejecutar `configurar-tpv.ps1 -CertificadoOdoo .\odoo.crt -PuertosOdoo 443` en los dos TPV (o aplicar a mano lo que falta) y comprobarlo con `comprobar-tpv.ps1` (tarea 15) | Markel | ⏳ Pendiente |
| S-21 | Baja | Tarea 19, `arduino/mando-joystick/subir.sh` | Instalaba la librería Joystick desde la rama principal de GitHub (con `ENABLE_UNSAFE_INSTALL`), sin fijar versión: cualquier cambio en esa rama entraría en el firmware sin revisar | Fijar la versión con la que se probó (`#v2.1.1`) | Adrian | ✅ Corregido el 27/10 (`LIB_VERSION`). La instalación no se pudo repetir: este PC no tiene `arduino-cli` |
| S-22 | Baja | Tarea 42, `08-usuarios.sql` | El ejemplo de uso pasaba las contraseñas de `tpv_app` e `informes` escritas en la orden (`-v pass_tpv='...'`), y el comentario decía que así no quedaban en el historial: sí quedan en `~/.bash_history` | Leerlas antes con `read -rs` y pasarlas como variable (mismo criterio que S-15) | Adrian | ✅ Corregido el 29/10 en el script y en la tarea 40 |
| S-23 | Media | Tarea 44, copia 3b a S3 | La copia a S3 necesita un usuario IAM con claves permanentes, y el Learner Lab no deja crear usuarios IAM: sus credenciales caducan en cada sesión. Con claves de la sesión, la copia nocturna fallaría en cuanto se pare el laboratorio; y unas claves con permisos de todo el laboratorio en el servidor serían peor que no tener la copia | En el laboratorio, dejar la 3b como diseño (la regla 3-2-1 ya la cumple el USB) y no guardar claves del Learner Lab en `s3.env`. En una cuenta de AWS normal: usuario IAM limitado al bucket, como dice la tarea 44 | Iker | ⏳ Pendiente |
| S-24 | Alta | Tarea 24, capturas del 29/10 | Las capturas 14 y 16 de la red segura dejaban leer la contraseña Wi-Fi nueva (el recuadro tapaba el campo de al lado), la misma en la red del personal y en la de invitados; la 15, el PIN de WPS. Las imágenes antiguas siguen en el historial de Git. Es lo mismo que S-05 | Cambiar la contraseña del personal, poner otra distinta en invitados (KeePassXC) y generar un PIN de WPS nuevo. Revisar cada captura ampliada antes de subirla | Peio | ✅ Corregido el 29/10: capturas tapadas, contraseñas Wi-Fi cambiadas (distintas en personal e invitados, en KeePassXC) y PIN de WPS nuevo (Peio) |
| S-25 | Media | Tareas 24 y 26, router | El TL-WR841N tiene **UPnP** activo (libupnp 1.6.19, de 2013) y **SSH** abierto en la LAN (Dropbear 2012.55), con firmware de Linux 2.6.36. Con UPnP cualquier equipo de la LAN (también la recreativa) puede abrir puertos hacia Internet sin pedir permiso | Desactivar UPnP (*Forwarding → UPnP*) y actualizar el firmware desde la web de TP-Link. Si el SSH no se puede quitar, se acepta: la administración ya está limitada a la MAC del gerente | Peio | ⏳ Pendiente (hallazgos H-01 y H-02 de la tarea 26) |
| S-26 | Baja | Tarea 34, `/root/.credenciales-usuarios` | Las contraseñas de cajeros y gerente que genera `configurar-odoo.py` se quedan en el servidor en claro (fichero 600 de root), y `ver-menus-usuarios.py` cuenta con que sigan ahí. Quien sacara una copia del disco o fuera root las leería todas | Pasarlas a KeePassXC y borrar el fichero (`sudo shred -u /root/.credenciales-usuarios`) al acabar las pruebas. Si hay que repetir `ver-menus-usuarios.py`, crearlo de nuevo solo para eso | Iker | ⏳ Pendiente |

## 4. Detalle

### 4.1 S-01: el certificado de Odoo podía firmar cualquier web (corregido)

El certificado propio de la tarea 52 hace de CA (`CA:TRUE`, `keyCertSign`) y se instala como **raíz de confianza** en los TPV y en el PC del gerente. Así un solo fichero sirve de certificado del servidor y de raíz. El problema era que no tenía límites: su clave privada (`/opt/odoo/https/certs/odoo.key`) podía firmar un certificado válido para cualquier dominio. Quien la sacara del servidor (o de una copia de seguridad, si además tuviera la contraseña de restic) podría hacerse pasar por cualquier web ante esos equipos.

**Arreglo.** `activar-https.sh` añade ahora:

```
nameConstraints=critical,permitted;IP:<IP>/255.255.255.255,permitted;DNS:odoo.almichain.local
```

La CA solo puede firmar para la IP del servidor y para `odoo.almichain.local`. El certificado de Odoo sigue siendo válido porque cumple esos límites.

**Prueba** ([evidencia 01](evidencias/01-certificado-odoo-nameconstraints.txt)): se generan los dos certificados (antes y ahora) con la orden del script y se firma con cada clave un certificado falso para `www.bancoejemplo.es`.

| | Certificado de antes | Certificado de ahora |
|---|---|---|
| Odoo (`192.168.10.10`) | Válido | Válido |
| Falso `www.bancoejemplo.es` | **Válido** | Rechazado: `permitted subtree violation` |

**Qué queda:**

- Comprobar en Edge, en el TPV, que Odoo carga sin avisos con el certificado nuevo. Es la prueba 5 de la tarea 52.
- ✅ Hecho el 26/10 a las 10:25 en la VM de pruebas de la tarea 52: se borró el certificado viejo y se volvió a ejecutar el script. El proxy sirve el certificado con `nameConstraints`, un cliente con la raíz lo valida (HTTP 200, verificación 0) y el resto de las pruebas sigue igual ([evidencia 05 de la tarea 52](../../erp/52-https-odoo/evidencias/05-certificado-con-nameconstraints.txt)).

### 4.2 S-08 y S-09: endurecer el servidor ERP

Comandos para la `ServidorERP` del equipo (como `tecnico`, con `sudo`). Antes de cerrar la contraseña, comprobar que se entra con la clave desde el PC del gerente.

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub tecnico@192.168.10.10
```

En el servidor:

```bash
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin no\n' | sudo tee /etc/ssh/sshd_config.d/10-endurecer.conf && sudo sshd -t && sudo systemctl reload ssh
```

```bash
sudo sed -i '/recreativa-claude/d' ~/.ssh/authorized_keys
```

```bash
sudo apt-get install -y unattended-upgrades && sudo dpkg-reconfigure -f noninteractive unattended-upgrades
```

Imágenes de Docker, una vez al mes y siempre después de una copia (`sudo systemctl start backup-odoo`):

```bash
cd /opt/odoo && sudo docker compose pull && sudo docker compose up -d
```

Lo mejor es añadir esto al preseed (`late_command`, como en el de la recreativa) para que no dependa de acordarse.

## 5. Comprobaciones manuales (capturas)

No se pueden hacer desde el repositorio. Cada una cierra o confirma un hallazgo. Guardarlas en `docs/seguridad/46-revision-seguridad/evidencias/`.

| # | Comprobación | Esperado | Hallazgo | Resultado |
|---|---|---|---|---|
| 1 | Desde un portátil en la Wi-Fi de invitados: `nmap -Pn -p 22,80,443,8069 192.168.10.0/24` | Todo `filtered` o sin respuesta | S-06, S-13 | ✅ 30/10 con el router real, desde un móvil con Termux (tarea 26, [sección 5.2](../../redes/26-analisis-conectividad/DOCUMENTACION.md)) |
| 2 | Desde la LAN: `nmap -p- 192.168.10.10` | Solo 22, 80 y 443 abiertos | S-02, S-09 | ◐ 03/11 en el laboratorio: solo escuchan 22, 80 y 443 hacia fuera; 8069 solo en `127.0.0.1` ([evidencia 02](evidencias/02-servidor-laboratorio-puertos-ssh.txt)). Falta el nmap desde la LAN con el servidor del equipo (tarea 26, L2) |
| 3 | Navegador del TPV: `https://192.168.10.10/pos/ui`, ver el certificado (candado) | Sin avisos; la huella coincide con la de `activar-https.sh` | S-01, S-02 | ◐ 26/10 en la VM (tarea 52, prueba 5). Falta en los TPV reales, con el runbook de la 52 |
| 4 | Panel del router: *System Tools → Password*, *Local Management* y *WPS* | Contraseña cambiada, solo la MAC del gerente, WPS desactivado | S-04 | ✅ 29/10 (tarea 24, [figuras 4 y 6](../../redes/24-red-segura/configurar-red-segura.md)) |
| 5 | Panel del router: *Wireless Security* | Contraseña nueva (tapada en la captura), clave de grupo con renovación | S-05, S-07 | ✅ 29/10 (tarea 24, [figura 3](../../redes/24-red-segura/configurar-red-segura.md)) |
| 6 | `ssh -o PubkeyAuthentication=no tecnico@192.168.10.10` | `Permission denied (publickey)` | S-08 | ❌ 03/11 en el laboratorio: `Permission denied (publickey,password)`, todavía admite contraseña ([evidencia 02](evidencias/02-servidor-laboratorio-puertos-ssh.txt)) |
| 7 | En el servidor: `systemctl status unattended-upgrades` | `active` | S-09 | ❌ 03/11 en el laboratorio: no está instalado ([evidencia 02](evidencias/02-servidor-laboratorio-puertos-ssh.txt)) |
| 8 | Batocera: menú *Sistema → Seguridad* | *Enforce security* activado; la contraseña ya no es `linux` | S-03 | ➖ No aplica (Debian, tarea 51) |
| 9 | PC del gerente: `manage-bde -status C:` y `lsblk -f` en Ubuntu | BitLocker activo; `/home/gerente` cifrado | S-11 | ✅ 29/10 en la VM ([BitLocker](../../evidencias/12-dual-boot/win-10-bitlocker-final.txt), [fscrypt](../../evidencias/12-dual-boot/ubu-09-fscrypt-home-gerente.txt)) |

## 6. Lo que ya está bien

Para no repetirlo en otras tareas y para la presentación:

- **Secretos fuera del repositorio:** contraseñas aleatorias en `.env` (600), KeePassXC, `.gitignore` con `.env`, `*.key`, `*.kdbx`, `*.tfvars` y `*.tfstate`, y gitleaks en el CI y en el hook local. La búsqueda de esta revisión no encontró ninguna contraseña en los scripts.
- **Odoo:** sin gestor ni listado de bases de datos (`list_db = False`, `dbfilter`), contraseña de `admin` cambiada al instalar, PostgreSQL sin publicar y, con la tarea 52, TLS 1.2/1.3, cookie `Secure` y `HttpOnly`, y 8069 cerrado en la LAN.
- **TPV:** cajero sin administrador, USB de almacenamiento bloqueado, firewall y Defender activos (comprobado en los TPV de la tarea 13). `configurar-tpv.ps1` añade la UAC que deniega la elevación, el firewall que bloquea la **salida** por defecto y Edge con lista blanca y sin descargas, pero eso aún no está en los TPV (S-20).
- **Base de datos:** roles de grupo `NOLOGIN`, facturas sin `UPDATE` ni `DELETE`, `REVOKE CONNECT … FROM PUBLIC` y límite de conexiones.
- **Copias:** restic cifrado (AES-256), contraseña en un fichero 600 y recordatorio de guardarla fuera, comprobación (`check`) en cada copia y aviso si el USB no se renueva.
- **Recreativa (Debian):** SSH solo con clave y sin root, usuario de juego sin `sudo` y con la contraseña bloqueada, `unattended-upgrades`.
- **Web en AWS:** bucket privado y cifrado, SSH limitado a una IP (Terraform rechaza `0.0.0.0/0`), IMDSv2, disco cifrado, HSTS, CSP estricta, `Permissions-Policy` y `server_tokens off`.

## 7. Pendiente

- [ ] Comprobaciones de la sección 5: hechas 1, 4, 5 y 9; la 8 no aplica; 2, 3, 6 y 7 en el laboratorio (03/11). Faltan 2 y 3 con el servidor y los TPV del equipo en la red, y repetir 6 y 7 cuando se aplique la sección 4.2.
- [ ] Pasar cada hallazgo a su responsable (columna de la sección 3) y marcarlo aquí cuando lo cierre.
- [ ] Repetir la revisión rápida antes de la entrega (10/11), con los hallazgos abiertos. Repasado hasta el PR #99 (secciones 1.1 a 1.3: 27/10, 29/10 y 03/11).
