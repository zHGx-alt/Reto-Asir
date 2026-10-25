# Tarea 52: Proxy HTTPS delante de Odoo

- **Bloque:** 7 ERP
- **Responsable:** Adrian
- **Depende de:** tarea 33 (Odoo con Docker)
- **Estado (24/10/2026):** ficheros listos; `activar-https.sh` pasa `bash -n`. **Falta ejecutarlo en la VM `ServidorERP`** y guardar las evidencias (sección 4).

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
| [`activar-https.sh`](activar-https.sh) | Genera el certificado, copia los ficheros, activa `proxy_mode` en Odoo, fija `COMPOSE_FILE` y levanta todo. Idempotente |

**Certificado propio.** La IP del servidor es privada, así que Let's Encrypt no puede emitir un certificado para ella. El script crea uno propio (válido 825 días, para `IP:192.168.10.10` y `odoo.almichain.local`) y hay que instalarlo como raíz de confianza en los TPV y en el PC del gerente. Así el navegador no da avisos y el *service worker* funciona.

## 3. Procedimiento

1. En el servidor, con una copia recién hecha (`sudo systemctl start backup-odoo`):
   ```bash
   cd docs/erp/52-https-odoo && sudo ./activar-https.sh 192.168.10.10
   ```
   Apuntar la huella SHA-256 que muestra.
2. Copiar `/opt/odoo/https/certs/odoo.crt` (solo el `.crt`, **nunca** el `.key`) a los TPV y al PC del gerente.
3. **TPV:** `.\configurar-tpv.ps1 -NumeroTpv 1 -CertificadoOdoo .\odoo.crt` ([tarea 13](../../so/13-tpv/DOCUMENTACION.md)) y cambiar la URL del quiosco a `https://192.168.10.10/pos/ui`. **Gerente:** en Windows, doble clic en el `.crt` → *Instalar certificado* → *Equipo local* → *Entidades de certificación raíz de confianza*; en Ubuntu, `sudo cp odoo.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates` (Firefox: importarlo en *Ajustes → Certificados*).
4. Comprobar que la huella que muestra el navegador coincide con la del paso 1.

## 4. Pruebas (evidencias en `docs/erp/52-https-odoo/evidencias/`)

| # | Prueba | Esperado |
|---|---|---|
| 1 | Salida de `activar-https.sh` | HTTPS 200, HTTP 301, 8069 cerrado |
| 2 | Desde el TPV, `https://192.168.10.10` | Candado sin avisos, login de Odoo |
| 3 | Desde otro equipo de la LAN, `http://192.168.10.10:8069` | No responde |
| 4 | `curl -I http://192.168.10.10` | `301` a `https://` |
| 5 | Venta completa en el TPV por HTTPS (tarea 34, sección 8.2) | Funciona igual |
| 6 | TPV sin red durante una venta (desconectar el cable), y volver a conectar | La venta se guarda y se sincroniza al volver la red |
| 7 | `backup-odoo.sh` y `probar-restauracion.sh` después del cambio | Siguen funcionando (usan `-f docker-compose.yml` y el servicio `db`, que no cambia) |

## 5. Volver atrás

```bash
cd /opt/odoo && sudo sed -i '/^COMPOSE_FILE=/d' .env && sudo sed -i '/proxy_mode\|Detrás del proxy HTTPS/d' config/odoo.conf
```

```bash
cd /opt/odoo && sudo docker compose -f docker-compose.yml up -d --remove-orphans
```

Odoo vuelve a escuchar en `8069` en la LAN. Hay que quitar `proxy_mode` (el primer comando lo hace): sin proxy delante, Odoo se fiaría de las cabeceras `X-Forwarded-*` que mandara cualquier cliente.
