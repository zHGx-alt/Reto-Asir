# Tarea 52: Proxy HTTPS delante de Odoo

- **Bloque:** 7 ERP
- **Responsable:** Adrian
- **Depende de:** tarea 33 (Odoo con Docker)
- **Estado (27/10/2026):** ✅ Hecha en máquina virtual, con las 15 pruebas correctas. Las pruebas 5 y 6 se hicieron con un TPV provisional (sección 4.2). El 27/10 el ticket se imprimió **desde la VM** del TPV, por IPP hacia la impresora del PC (sección 4.2, *Impresión*). Para pasarla a la `ServidorERP` del equipo está el [runbook](RUNBOOK.md).

## 1. Por qué

El enunciado pide «comunicaciones cifradas». Hoy Odoo va por **HTTP** en la LAN: las contraseñas de los cajeros y del gerente, y las ventas, viajan sin cifrar por el cable y por la Wi-Fi del personal. Además, el TPV de Odoo solo puede seguir cobrando sin red (su *service worker*) si la página se sirve por HTTPS.

## 2. Cómo queda

```
TPV / gerente ──HTTPS 443──► proxy (nginx) ──HTTP, red Docker "interna"──► odoo:8069 ──► db (PostgreSQL)
                 HTTP 80 ──► 301 a HTTPS
Odoo en el servidor: solo 127.0.0.1:8069 (ya no escucha en la LAN)
```

| Fichero | Qué hace |
|---|---|
| [`docker-compose.https.yml`](docker-compose.https.yml) | Añade el servicio `proxy` (nginx 1.27) y deja el puerto de Odoo solo en `127.0.0.1`. No cambia el `docker-compose.yml` de la tarea 33 |
| [`nginx.conf`](nginx.conf) | TLS 1.2/1.3, redirección de 80 a 443, cabeceras de seguridad, `/websocket` para el chat y los avisos |
| [`fijar-url-y-qr.sh`](fijar-url-y-qr.sh) | Fija la URL de Odoo y quita el QR de factura del ticket (tarea 46, S-19) |
| [`activar-https.sh`](activar-https.sh) | Genera el certificado, copia los ficheros, activa `proxy_mode` en Odoo, fija `COMPOSE_FILE` y levanta todo. Idempotente |

**Certificado propio.** La IP del servidor es privada, así que Let's Encrypt no puede emitir un certificado para ella. El script crea uno propio (válido 825 días, para `IP:192.168.10.10` y `odoo.almichain.local`) y hay que instalarlo como raíz de confianza en los TPV y en el PC del gerente. Así el navegador no da avisos y el *service worker* funciona. Desde el 26/10 lleva `nameConstraints`: solo vale para esa IP y ese nombre, así que aunque robaran `odoo.key` no serviría para suplantar otras webs ([tarea 46, S-01](../../seguridad/46-revision-seguridad/DOCUMENTACION.md#41-s-01-el-certificado-de-odoo-podía-firmar-cualquier-web-corregido)).

## 3. Procedimiento

1. En el servidor, con una copia recién hecha (`sudo systemctl start backup-odoo`):
   ```bash
   cd docs/erp/52-https-odoo && sudo ./activar-https.sh 192.168.10.10
   ```
   Apuntar la huella SHA-256 que muestra.
2. Copiar `/opt/odoo/https/certs/odoo.crt` (solo el `.crt`, **nunca** el `.key`) a los TPV y al PC del gerente.
3. **TPV:** `.\configurar-tpv.ps1 -NumeroTpv 1 -CertificadoOdoo .\odoo.crt` ([tarea 13](../../so/13-tpv/DOCUMENTACION.md)) y cambiar la URL del quiosco a `https://192.168.10.10/pos/ui`. **Gerente:** en Windows, doble clic en el `.crt` → *Instalar certificado* → *Equipo local* → *Entidades de certificación raíz de confianza*; en Ubuntu, `sudo cp odoo.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates` (Firefox: importarlo en *Ajustes → Certificados*).
4. Comprobar que la huella que muestra el navegador coincide con la del paso 1.

## 4. Pruebas (26/10/2026)

**Montaje.** VM `ServidorERP` nueva, hecha con la [tarea 33](../33-odoo-docker/DOCUMENTACION.md): Debian 13.7, Odoo 19.0-20261015 y PostgreSQL 17. Tiene red NAT de VirtualBox, así que su IP es `10.0.2.15` y el script se ejecutó con `sudo ./activar-https.sh 10.0.2.15`. El PC anfitrión hace de «otro equipo de la LAN» con los reenvíos `127.0.0.1:8443 → 443`, `:8080 → 80` y `:8069 → 8069`. En el local se usa `192.168.10.10`, igual que en la sección 3.

Huella SHA-256 del certificado de la VM: `80:59:38:33:4F:3E:43:DA:8A:C2:B3:7B:35:E0:57:7E:EA:C0:52:3A:E6:52:29:C7:2E:64:49:9A:FE:71:11:F8`. Es el regenerado a las 10:25 con `nameConstraints` ([tarea 46, S-01](../../seguridad/46-revision-seguridad/DOCUMENTACION.md)); con él se repitieron las pruebas 2, 3, 4, 8, 9 y 12, todas correctas ([05](evidencias/05-certificado-con-nameconstraints.txt)). El de las 07:15 (`DE:72:15:…:0B:82`) ya no existe. En el servidor del local saldrá otra, porque el certificado se genera allí.

| # | Prueba | Esperado | Resultado | Evidencia |
|---|---|---|---|---|
| 1 | Salida de `activar-https.sh` | HTTPS 200, HTTP 301, 8069 cerrado | ✅ 200 · 301 a `https://10.0.2.15/web/login` · 000 | [01](evidencias/01-activar-https.txt) |
| 2 | HTTPS validando el certificado, como un TPV con la raíz instalada | Sin avisos, login de Odoo | ✅ HTTP 200, verificación TLS correcta (`curl --cacert`, sin `-k`). Sin la raíz: `self-signed certificate`, que es lo que verá un navegador al que no se le ha instalado | [02](evidencias/02-pruebas-desde-la-lan.txt) |
| 3 | Desde otro equipo, `http://<servidor>:8069` | No responde | ✅ 000: Odoo solo escucha en `127.0.0.1` | [02](evidencias/02-pruebas-desde-la-lan.txt) |
| 4 | `curl -I http://<servidor>` | `301` a `https://` | ✅ `301 Moved Permanently` | [02](evidencias/02-pruebas-desde-la-lan.txt) |
| 5 | Venta completa en el TPV por HTTPS (tarea 34, sección 8.2) | Funciona igual | ✅ Edge con candado y sin avisos; `cajero1` solo ve Punto de venta; mesa 3, 7,30 € en efectivo, factura simplificada `261-1-000003` (sección 4.2) | [06](evidencias/06-ventas-en-el-servidor.txt), [07](evidencias/07-certificado-instalado-tpv.webp), [08](evidencias/08-tpv-cajero1-https.png), [09](evidencias/09-ticket-venta-https.webp) |
| 6 | TPV sin red durante una venta (desconectar el cable), y volver a conectar | La venta se guarda y se sincroniza al volver la red | ✅ Con el cable quitado, «Conexión perdida» y aun así «Pago exitoso» (mesa 4, 5,00 €). Al reconectar, el pedido `261-1-000004` aparece en el servidor como `paid` | [06](evidencias/06-ventas-en-el-servidor.txt), [10](evidencias/10-venta-sin-red.png), [11](evidencias/11-reconectado.png) |
| 7 | Backup después del cambio | Sigue funcionando | ✅ `pg_dump` con `-f docker-compose.yml` y el servicio `db`, como en `backup-odoo.sh`: copia válida (cabecera `PGDMP`, 134 tablas con datos) y el proxy sigue en marcha. El backup completo no se pudo lanzar: en esta VM no hay RAID ni USB (tareas 43 y 44) | [03](evidencias/03-reejecucion-y-backup.txt) |
| 8 | TLS 1.0 y 1.1 | Rechazados | ✅ Rechazados; 1.2 y 1.3 aceptados | [02](evidencias/02-pruebas-desde-la-lan.txt) |
| 9 | Cabeceras de seguridad | Cada una, una vez | ✅ `nosniff`, `SAMEORIGIN`, `strict-origin-when-cross-origin` (incidencia 3) | [02](evidencias/02-pruebas-desde-la-lan.txt) |
| 10 | `/websocket` (chat y avisos) a través del proxy | `101 Switching Protocols` | ✅ 101 | [02](evidencias/02-pruebas-desde-la-lan.txt) |
| 11 | Login por HTTPS | `admin` entra; `admin/admin` no | ✅ uid 2; `admin/admin` da `AccessDenied` | [04](evidencias/04-login-https.txt) |
| 12 | Cookie de sesión | `HttpOnly` y `Secure` | ✅ Las dos (incidencia 4) | [04](evidencias/04-login-https.txt) |
| 13 | `proxy_mode` | Odoo redirige a `https://` | ✅ `/odoo` sin sesión → `303 https://10.0.2.15/web/login` | [04](evidencias/04-login-https.txt) |
| 14 | Volver a ejecutar el script | Idempotente; mantiene el certificado | ✅ «Ya existe: se mantiene», misma huella | [03](evidencias/03-reejecucion-y-backup.txt) |
| 15 | Permisos | Clave privada no legible por otros | ✅ `odoo.key` 640 root, carpeta `certs` 750, `.env` 600 | [03](evidencias/03-reejecucion-y-backup.txt) |

## 4.1 Incidencias

| # | Incidencia | Causa | Solución |
|---|---|---|---|
| 1 | `sudo ./activar-https.sh`: *command not found* | El script estaba en git sin permiso de ejecución (`100644`) | `git update-index --chmod=+x` |
| 2 | Al desplegar Odoo (tarea 33), `apt` no conectaba con `deb.debian.org` | La VM resuelve `deb.debian.org` solo por IPv6, y la red NAT de VirtualBox no tiene salida IPv6 | En la VM: `Acquire::ForceIPv4 "true";` en `/etc/apt/apt.conf.d/99ipv4`. Es cosa del laboratorio; en el local, con IPv4 e IPv6 o solo IPv4, no hace falta |
| 3 | `X-Frame-Options` y `X-Content-Type-Options` llegaban duplicadas | Odoo ya las manda y nginx las volvía a añadir | `proxy_hide_header` de las dos en `nginx.conf` |
| 4 | La cookie `session_id` iba sin `Secure` | Odoo no la marca, aunque sepa que va detrás de HTTPS. Si alguien teclea `http://` con la sesión abierta, el navegador la mandaría en claro antes del 301 | `proxy_cookie_flags session_id secure;` en `nginx.conf` |
| 5 | Al cambiar `nginx.conf` y volver a ejecutar el script, el proxy seguía con la configuración vieja | `install` deja el fichero como uno nuevo, el contenedor seguía con el antiguo montado y `docker compose up` no lo recrea si el compose no cambia | El script recrea el proxy al final (`up -d --force-recreate --no-deps proxy`) |
| 6 | El QR «¿Necesita una factura?» del ticket apunta a `https://10.0.2.15/pos/ticket`, la IP antigua de la VM | Odoo guarda `web.base.url` la primera vez que entra el administrador y no la cambia aunque cambie la IP. Además, el cliente está en la Wi-Fi de invitados, que no llega al servidor | Hallazgo S-19 de la [tarea 46](../../seguridad/46-revision-seguridad/DOCUMENTACION.md). [`fijar-url-y-qr.sh`](fijar-url-y-qr.sh): fija `web.base.url` (con `freeze`) y quita el QR. Probado en la VM: con una sesión de caja nueva el ticket ya no lleva QR ([13](evidencias/13-fijar-url-y-qr.txt), [14](evidencias/14-recibo-misma-sesion-con-qr.png), [15](evidencias/15-recibo-sesion-nueva-sin-qr.png)). En el servidor del equipo, paso 2.1 del runbook |
| 7 | `certutil -hashfile odoo.crt SHA256` no coincidía con la huella del certificado | Calcula la suma del fichero (texto PEM), no la del certificado | Runbook corregido: la huella se mira con `Get-PfxCertificate` |

## 4.2 Pruebas 5 y 6 con un TPV provisional (26/10/2026)

Los TPV de la tarea 13 están en el PC de Markel y todavía no se han conectado a Odoo. Para no esperar, las pruebas se hicieron en el PC de Adrian con la misma red que el plano (tarea 23):

| Pieza | Montaje |
|---|---|
| Red | Red NAT de VirtualBox `reto-lan`, `192.168.10.0/24`, puerta de enlace `192.168.10.1` (como el router). DHCP con reserva para el servidor |
| Servidor | La misma VM `ServidorERP`, ahora en `192.168.10.10`. Certificado regenerado para esa IP con `nameConstraints` (huella SHA-256 `04:3E:61:A7:61:1F:6E:BC:83:A9:1C:EC:1A:1C:D5:29:B6:72:84:0B:7B:86:E4:E5:79:4D:2F:8E:45:EF:9B:DE`) y Odoo configurado con los scripts de la tarea 34 |
| TPV | VM `win-11` personal de Adrian (no es del proyecto, se usó solo para estas pruebas) en `192.168.10.60`, con el `.crt` como raíz de confianza (`certutil -addstore Root`, en un PowerShell de administrador) |

No es el TPV definitivo (es una VM personal con Windows 11, sin el bastionado de `configurar-tpv.ps1`), así que **se repiten en los TPV reales** al activar el proxy en el servidor del equipo ([runbook](RUNBOOK.md), paso 5). Lo que demuestran ya: Edge acepta el certificado con `nameConstraints`, el TPV de Odoo funciona igual por HTTPS y cobra sin red.

**Impresión.** La impresora USB (una Samsung ML-1660 láser, en lugar de la térmica del centro) se pasó a la VM, pero Windows no creó el puerto `USB001` y el trabajo falló ([12](evidencias/12-impresora-en-la-vm-error.png)). El ticket de la foto [09](evidencias/09-ticket-venta-https.webp) es el de la venta por HTTPS, pero salió por el CUPS del PC anfitrión: no salió de la VM.

El 27/10 se imprimió desde la VM sin pasar el USB: la `win-11` manda el trabajo por **IPP** a la cola CUPS del PC, que tiene la impresora conectada. En el PC se cambió a mano `/etc/cups/cupsd.conf` (necesita `sudo`):

| Línea | Para qué |
|---|---|
| `Listen 172.17.0.1:631` | CUPS escucha también en la IP de `docker0`, que la VM alcanza por el NAT de `reto-lan` y que no se ve desde la LAN |
| `ServerAlias 172.17.0.1` | Sin ella, CUPS responde 400 a una petición con ese nombre de host |
| `Allow from 172.17.0.1` y `Allow from 192.168.1.101` en `<Location />` | Solo se permite el propio PC. CUPS registra la conexión con la IP de LAN del PC (`192.168.1.101`, la da el DHCP del router: si cambia, hay que cambiar la regla) |

El mapeo de loopback de `reto-lan` (`192.168.10.2` → `127.0.0.1`) no sirve: a una conexión desde `127.0.0.1` CUPS solo le acepta `localhost` como nombre y ignora `ServerAlias`. En Windows, *Agregar impresora → Seleccionar una impresora compartida por nombre* → `http://172.17.0.1:631/printers/ML-1660-Series`, con el controlador **Microsoft PS Class Driver** (el filtro de la ML-1660 lo aplica CUPS). Venta de la Mesa 6 en *TPV Barra 1* (factura simplificada `261-1-000007`), *Imprimir recibo* en Edge: el ticket sale en papel y ya **sin el QR** (S-19, [16](evidencias/16-ticket-impreso-desde-vm.webp)). En el registro de CUPS el trabajo es del usuario de Windows de la VM, no del PC ([17](evidencias/17-cups-trabajo-desde-vm.txt)).

Con este ticket se da por hecha la **tarea 37**: el equipo decidió el 27/10 que la impresora de las pruebas es la Samsung, porque las térmicas del centro no llegan para todos los grupos. En la tienda real sigue siendo la térmica por USB al TPV (tarea 8); con ella solo cambian el driver y el puerto (tarea 14).

## 4.3 Cómo conectarse al laboratorio

Todo está en el PC de Adrian: las VM no se ven desde otros equipos. Las contraseñas no van en el repositorio, sino en el KeePassXC del equipo.

| Para | Dirección | Usuario |
|---|---|---|
| Odoo (gerente o administrador), desde la red `reto-lan` | `https://192.168.10.10/web/login` | `admin` |
| TPV de Odoo (quiosco del TPV) | `https://192.168.10.10/pos/ui` | `cajero1` |
| Odoo desde el propio PC | `https://127.0.0.1:8443/web/login` (el navegador avisa: el certificado solo vale para `192.168.10.10`) | `admin` |
| SSH al servidor, desde el PC | `ssh -p 2223 tecnico@127.0.0.1` | `tecnico`, con la clave `id_ed25519` de Adrian (es la única en `authorized_keys`) |
| Impresora, desde la VM del TPV | `http://172.17.0.1:631/printers/ML-1660-Series` (sección 4.2, *Impresión*) | — |

- El HTTP (`http://192.168.10.10`, o `http://127.0.0.1:8080` desde el PC) redirige a HTTPS.
- `tecnico` tiene `sudo` con contraseña. Esa contraseña también vale en la consola de VirtualBox.
- Para usar la VM en otro PC, se arranca su `.vmdk`: el reenvío de puertos de la red `reto-lan` solo escucha en `127.0.0.1`.

## 5. Volver atrás

```bash
cd /opt/odoo && sudo sed -i '/^COMPOSE_FILE=/d' .env && sudo sed -i '/proxy_mode\|Detrás del proxy HTTPS/d' config/odoo.conf
```

```bash
cd /opt/odoo && sudo docker compose -f docker-compose.yml up -d --remove-orphans
```

Odoo vuelve a escuchar en `8069` en la LAN. Hay que quitar `proxy_mode` (el primer comando lo hace): sin proxy delante, Odoo se fiaría de las cabeceras `X-Forwarded-*` que mandara cualquier cliente.
