# Tarea 46: Revisión de seguridad transversal

- **Bloque:** 10 Seguridad
- **Responsable:** Adrian
- **Depende de:** tareas 13, 24, 30, 42 y 52
- **Estado (26/10/2026):** 🟡 Revisión del repositorio hecha: 19 hallazgos y 2 ya corregidos (S-01 y S-05). Faltan las comprobaciones en los equipos (sección 5) y que cada responsable cierre los suyos (sección 3).

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

## 2. Resumen

| Gravedad | Hallazgos | Corregidos |
|---|---|---|
| Alta | 5 (S-01 a S-05) | 2 (S-01 y S-05) |
| Media | 7 (S-06 a S-12) | 0 |
| Baja | 7 (S-13 a S-19) | 0 |

Lo más urgente, por este orden:

1. **Router:** red de invitados sin hacer, y administración abierta a toda la LAN y WPS (S-06, S-04). Las contraseñas ya están cambiadas (26/10). La segmentación de la tarea 23 depende de esto.
2. **Odoo sigue por HTTP en la LAN** hasta activar la tarea 52 en el servidor del equipo (S-02).
3. **Batocera con la contraseña de root `linux`**, si se queda Batocera (S-03).

## 3. Hallazgos

| ID | Gravedad | Dónde | Qué pasa | Qué hacer | Responsable | Estado |
|---|---|---|---|---|---|---|
| S-01 | Alta | Tarea 52, `activar-https.sh` | El certificado de Odoo es una CA (`CA:TRUE`) sin límites, y se instala como raíz de confianza en los TPV y en el PC del gerente. Quien robara `odoo.key` del servidor podría firmar certificados de **cualquier** web (banco, correo) y los TPV se los creerían | Añadir `nameConstraints` para que solo valga para `192.168.10.10` y `odoo.almichain.local` | Adrian | ✅ Corregido en el script y probado en la VM de la tarea 52, también en Edge (candado sin avisos) (sección 4.1). Se aplica al generar el certificado en el servidor del equipo |
| S-02 | Alta | Tareas 33 y 52 | Odoo va por **HTTP** en la LAN: contraseñas de cajeros y del gerente y ventas sin cifrar | Activar el proxy en la `ServidorERP` del equipo e instalar el `.crt` en los TPV | Adrian | ⏳ Probado entero en VM, con TPV provisional y venta sin red (tarea 52, sección 4.2). Falta en el servidor del equipo: espera a la tarea 43 ([runbook](../../erp/52-https-odoo/RUNBOOK.md)) |
| S-03 | Alta | Tarea 16, Batocera | Con *Enforce security* desactivado, root tiene siempre la contraseña `linux`, se ve en el menú y sirve también para SSH y Samba | `batocera-settings-set system.security.enabled 1` y contraseña de root aleatoria en KeePassXC. O quedarse con la versión Debian, que ya está endurecida (S-08 lo compara) | Iker | ⏳ Pendiente (solo si se elige Batocera) |
| S-04 | Alta | Tarea 24, router | Se entra al panel como `Admin` con una contraseña de 5 caracteres que parece la de fábrica. El panel va por HTTP y está abierto a toda la LAN. No hay evidencia de que WPS esté apagado | Contraseña de KeePassXC, administración solo desde la MAC del gerente y por cable, y WPS desactivado | Peio | 🟡 Contraseña cambiada y en KeePassXC (26/10). Faltan la MAC y WPS |
| S-05 | Alta | Tarea 24, Wi-Fi | La contraseña Wi-Fi tiene 8 cifras y se leía en dos capturas que siguen en el historial de Git (commits `532c87a` y `215eac7`). El repositorio es privado, lo que lo atenúa, pero el profesor y cualquiera con acceso las pueden ver | Cambiarla por una frase de 20 caracteres o más. No hace falta reescribir el historial si se cambia la contraseña | Peio | ✅ Cambiada y en KeePassXC (26/10). Comprobar que la RADIUS de las mismas capturas tampoco sigue en uso |
| S-06 | Media | Tareas 23 y 24 | La red de invitados no está configurada. La tabla 5.2 de la tarea 23 confía en ella para que clientes y recreativa no lleguen al servidor ni a los TPV | Red `192.168.50.0/24` sin acceso a la LAN y con aislamiento entre clientes; pruebas 3 a 5 de la tarea 23 | Peio | ⏳ Pendiente |
| S-07 | Media | Tarea 24 | El TL-WR841N no tiene WPA3. Queda WPA2-AES, con la clave de grupo sin renovar (`0`) y modo `11bgn` | WPA3 (o WPA2/WPA3) en el Archer C6, renovación de la clave de grupo cada 3600 s y sin 802.11b. Si no se compra, dejarlo como limitación | Peio | ⏳ Pendiente |
| S-08 | Media | Tarea 33, `preseed-servidor.cfg` | El SSH del servidor admite contraseña (el preseed de la recreativa sí lo cierra y el del servidor no). Además, la única clave autorizada es la del laboratorio (`recreativa-claude`), no la del PC del gerente | Ver sección 4.2 | Iker | ⏳ Pendiente |
| S-09 | Media | Tareas 33 y 52 | El servidor no tiene `unattended-upgrades` (el preseed no lo instala y Debian sin escritorio no lo trae). Las imágenes `odoo:19.0`, `postgres:17` y `nginx:1.27-alpine` no tienen un procedimiento de actualización | Ver sección 4.2 | Iker | ⏳ Pendiente |
| S-10 | Media | Tarea 33, `docker-compose.yml` | Odoo se conecta a PostgreSQL con el usuario de `POSTGRES_USER`, que la imagen de PostgreSQL crea como **superusuario**. Choca con los mínimos privilegios de la tarea 42. Lo atenúa que PostgreSQL no está publicado fuera de Docker | Mejora para un despliegue nuevo: un rol `odoo` con `CREATEDB` y sin `SUPERUSER`. Hoy se acepta y se documenta, porque cambiarlo con datos reales tiene riesgo | Iker | Aceptado (riesgo documentado) |
| S-11 | Media | Tareas 12 y 13 | Ni el PC del gerente (BitLocker desactivado para el arranque dual, Ubuntu sin LUKS) ni los TPV tienen el disco cifrado. Si roban el equipo, se leen los datos sin contraseña | BitLocker en Windows y LUKS en `/home/gerente` (tarea 12, sección 9). BitLocker en los TPV (Pro e IoT Enterprise lo incluyen) | Adrian (12), Markel (13) | ⏳ Pendiente |
| S-12 | Media | Tareas 12 y 13 | Windows 10 dejó de tener soporte el 14/10/2025. Sin ESU o LTSC, el PC del gerente y los TPV no reciben parches. La VM del gerente sigue con la actualización de noviembre de 2022 | TPV: IoT Enterprise LTSC 2021 (soporte hasta 2032), decisión pendiente en la tarea 13. Gerente: ESU, o usar Ubuntu para el trabajo diario y dejar Windows solo para lo imprescindible | Markel, Adrian | ⏳ Pendiente |
| S-13 | Baja | Tarea 52 y Docker | `ufw` no filtra los puertos que publica Docker: la regla «80/443 solo desde la LAN» de `cortafuegos-servidor.sh` no se aplica al proxy. Con la red de invitados aislada (S-06) no hay ruta hasta él, así que el impacto es bajo | Comprobarlo con nmap desde la red de invitados (sección 5). Si llega, regla en la cadena `DOCKER-USER` | Adrian | ⏳ Pendiente de comprobar |
| S-14 | Baja | Tareas 13 y 52 | `configurar-tpv.ps1` permite por defecto los puertos 8069 y 443. Con el proxy activo, el TPV podría seguir abriendo `http://…:8069` (el servidor lo tiene cerrado, pero no es la configuración mínima) | Volver a ejecutarlo con `-PuertosOdoo 443` después de activar HTTPS (lo hace el runbook de la tarea 52) | Markel | ⏳ Con la tarea 52 |
| S-15 | Baja | Tareas 34 a 36 | Los scripts se lanzan con `ODOO_PASSWORD=... python3 …`. La contraseña queda en `~/.bash_history` | `read -rs ODOO_PASSWORD && export ODOO_PASSWORD` antes de ejecutarlos. Cambiarlo en los ejemplos de uso | Iker, Eneko.P | ⏳ Pendiente |
| S-16 | Baja | Tarea 31, `user-data.sh.tftpl` | El token de DuckDNS va en el `user_data`. Lo puede leer cualquier proceso de la EC2 (IMDS) y queda en claro en `terraform.tfstate`. `.gitignore` excluye el `tfstate`, así que no llega al repositorio | Aceptable en el laboratorio. En producción: guardarlo en SSM Parameter Store y leerlo desde la instancia | Eneko.P | Aceptado |
| S-17 | Baja | Tarea 30 | `LabInstanceProfile` tiene más permisos de los que necesita la EC2 (solo leer un bucket). Ya está documentado como limitación del Learner Lab | Nada en el laboratorio. En producción, un rol con `s3:GetObject` y `s3:ListBucket` | Adrian | Aceptado (limitación) |
| S-18 | Baja | `.github/workflows/` | Las acciones se referencian por etiqueta (`actions/checkout@v4`), no por SHA. Si alguien moviera la etiqueta, se ejecutaría otro código con los secretos de AWS | Fijarlas por SHA en `desplegar-web.yml`, que es el que usa secretos | Eneko.P | ⏳ Pendiente |
| S-19 | Baja | Tareas 34 y 52, ticket del TPV | El QR «¿Necesita una factura?» del ticket apunta a la IP vieja del servidor (`web.base.url` no se actualiza). Aunque apuntara bien, el cliente está en la Wi-Fi de invitados, que no llega al servidor: el QR invita a una dirección interna que no le sirve | Fijar `web.base.url` y `web.base.url.freeze` y quitar el QR del recibo (runbook de la tarea 52, paso 2.1) | Adrian | ⏳ Con la tarea 52 |

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

| # | Comprobación | Esperado | Hallazgo |
|---|---|---|---|
| 1 | Desde un portátil en la Wi-Fi de invitados: `nmap -Pn -p 22,80,443,8069 192.168.10.0/24` | Todo `filtered` o sin respuesta | S-06, S-13 |
| 2 | Desde la LAN: `nmap -p- 192.168.10.10` | Solo 22, 80 y 443 abiertos | S-02, S-09 |
| 3 | Navegador del TPV: `https://192.168.10.10/pos/ui`, ver el certificado (candado) | Sin avisos; la huella coincide con la de `activar-https.sh` | S-01, S-02 |
| 4 | Panel del router: *System Tools → Password*, *Local Management* y *WPS* | Contraseña cambiada, solo la MAC del gerente, WPS desactivado | S-04 |
| 5 | Panel del router: *Wireless Security* | Contraseña nueva (tapada en la captura), clave de grupo con renovación | S-05, S-07 |
| 6 | `ssh -o PubkeyAuthentication=no tecnico@192.168.10.10` | `Permission denied (publickey)` | S-08 |
| 7 | En el servidor: `systemctl status unattended-upgrades` | `active` | S-09 |
| 8 | Batocera: menú *Sistema → Seguridad* | *Enforce security* activado; la contraseña ya no es `linux` | S-03 |
| 9 | PC del gerente: `manage-bde -status C:` y `lsblk -f` en Ubuntu | BitLocker activo; `/home/gerente` en LUKS | S-11 |

## 6. Lo que ya está bien

Para no repetirlo en otras tareas y para la presentación:

- **Secretos fuera del repositorio:** contraseñas aleatorias en `.env` (600), KeePassXC, `.gitignore` con `.env`, `*.key`, `*.kdbx`, `*.tfvars` y `*.tfstate`, y gitleaks en el CI y en el hook local. La búsqueda de esta revisión no encontró ninguna contraseña en los scripts.
- **Odoo:** sin gestor ni listado de bases de datos (`list_db = False`, `dbfilter`), contraseña de `admin` cambiada al instalar, PostgreSQL sin publicar y, con la tarea 52, TLS 1.2/1.3, cookie `Secure` y `HttpOnly`, y 8069 cerrado en la LAN.
- **TPV:** cajero sin administrador, UAC que deniega la elevación, USB de almacenamiento bloqueado, firewall que bloquea la **salida** por defecto, Edge con lista blanca y sin descargas.
- **Base de datos:** roles de grupo `NOLOGIN`, facturas sin `UPDATE` ni `DELETE`, `REVOKE CONNECT … FROM PUBLIC` y límite de conexiones.
- **Copias:** restic cifrado (AES-256), contraseña en un fichero 600 y recordatorio de guardarla fuera, comprobación (`check`) en cada copia y aviso si el USB no se renueva.
- **Recreativa (Debian):** SSH solo con clave y sin root, usuario de juego sin `sudo` y con la contraseña bloqueada, `unattended-upgrades`.
- **Web en AWS:** bucket privado y cifrado, SSH limitado a una IP (Terraform rechaza `0.0.0.0/0`), IMDSv2, disco cifrado, HSTS, CSP estricta, `Permissions-Policy` y `server_tokens off`.

## 7. Pendiente

- [ ] Hacer las comprobaciones de la sección 5 y guardar las capturas.
- [ ] Pasar cada hallazgo a su responsable (columna de la sección 3) y marcarlo aquí cuando lo cierre.
- [ ] Repetir la revisión rápida antes de la entrega (10/11), con los hallazgos abiertos.
