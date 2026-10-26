# Tarea 52 · Runbook: activar HTTPS en la ServidorERP del equipo

Lo que falta para cerrar la tarea 52 (y el hallazgo S-02 de la [tarea 46](../../seguridad/46-revision-seguridad/DOCUMENTACION.md)). En la VM de pruebas ya está hecho y probado ([DOCUMENTACION.md](DOCUMENTACION.md), sección 4). Esto es el orden para el servidor de verdad y los TPV, con las capturas que hay que sacar en cada paso.

**Tiempo:** unos 45 minutos, con el local cerrado: Odoo se reinicia en el paso 2.

## 0. Antes de empezar

| Comprobación | Cómo | Si falla |
|---|---|---|
| La BD ya está en el RAID (tarea 43, sección 7) | `sudo docker info --format '{{.DockerRootDir}}'` → `/srv/datos/docker` | Parar: primero `sudo ./mover-docker-al-raid.sh` (Iker). Si no, el paso 2 se hace sobre unos datos que luego se mueven |
| Docker Compose 2.24 o posterior | `docker compose version --short` | `activar-https.sh` lo comprueba y para. Actualizar `docker-compose` |
| El repositorio está al día en el servidor | `git -C ~/Reto-Asir pull` | El script tiene que llevar `nameConstraints` (tarea 46, S-01): `grep -c nameConstraints docs/erp/52-https-odoo/activar-https.sh` → `1` |
| No hay ya un certificado viejo | `sudo ls /opt/odoo/https/certs/` → no existe | Si es de una prueba anterior (sin `nameConstraints`), `sudo rm -r /opt/odoo/https/certs` antes del paso 2 |
| El TPV 1 está bastionado (tarea 13) | `comprobar-tpv.ps1` da 16 OK | Pasos 4 y 5 hasta que Markel lo termine |

## 1. Copia de seguridad

```bash
sudo systemctl start backup-odoo && journalctl -u backup-odoo -n 5 --no-pager
```

Tiene que acabar en «Copia terminada correctamente» o, sin el USB, en el aviso del USB. Si falla, no seguir.

## 2. Activar el proxy

```bash
cd ~/Reto-Asir/docs/erp/52-https-odoo && sudo ./activar-https.sh 192.168.10.10 | tee ~/52-activar-https.txt
```

Esperado al final: `HTTPS: 200`, `HTTP → 443: 301`, `8069 en la LAN: 000`.

- **Apuntar la huella SHA-256** que muestra el paso 1/5. Se compara en los pasos 4 y 6.
- Comprobar que el certificado tiene los límites:
  ```bash
  sudo openssl x509 -in /opt/odoo/https/certs/odoo.crt -noout -ext subjectAltName,nameConstraints
  ```
- **Evidencia:** copiar `~/52-activar-https.txt` a `docs/erp/52-https-odoo/evidencias/05-activar-https-servidor-equipo.txt`.

Si algo va mal: sección 5 de [DOCUMENTACION.md](DOCUMENTACION.md) (volver atrás en dos órdenes).

## 3. Cortafuegos del servidor

Si ya se ejecutó en la tarea 33, se vuelve a ejecutar sin problema (es idempotente):

```bash
cd ~/Reto-Asir/docs/erp/33-odoo-docker && sudo ./cortafuegos-servidor.sh
```

## 4. Los dos TPV

1. Copiar `/opt/odoo/https/certs/odoo.crt` (**nunca** el `.key`) a un USB **antes** de que el TPV bloquee los USB, o por `scp` al PC del gerente y de ahí al TPV.
   ```bash
   sudo install -m 644 /opt/odoo/https/certs/odoo.crt ~/odoo.crt
   ```
2. En el TPV, PowerShell como administrador, desde `docs/so/13-tpv`. `-PuertosOdoo 443` quita el 8069 del firewall y de la lista de Edge (tarea 46, S-14):
   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   ```
   ```powershell
   .\configurar-tpv.ps1 -NumeroTpv 1 -PuertosOdoo 443 -CertificadoOdoo .\odoo.crt
   ```
   La huella que muestra es SHA-1 (`Thumbprint`). Para comparar con la SHA-256 del paso 2: `certutil -hashfile .\odoo.crt SHA256`.
3. Cambiar la URL del quiosco a `https://192.168.10.10/pos/ui` (tarea 13, paso 4.5: *Configurar un quiosco* → elegir el existente → URL).
4. Comprobar:
   ```powershell
   .\comprobar-tpv.ps1 -PuertoOdoo 443 -Salida ..\..\evidencias\13-tpv\tpv1-comprobacion-https.txt
   ```
5. Repetir en el TPV 2 con `-NumeroTpv 2`.

## 5. Pruebas 5 y 6 (las que faltan)

| # | Qué hacer | Esperado | Captura |
|---|---|---|---|
| 5 | En el TPV 1 como `cajero1`: abrir caja, vender 2 productos, cobrar en efectivo e imprimir el ticket (tarea 34, sección 8.2) | Igual que por HTTP | `evidencias/05-venta-https.png`: el TPV con la venta hecha. Antes, salir del quiosco y sacar una de Edge con el candado y el certificado abierto (*Ver certificado* → huella), `evidencias/05-certificado-tpv.png` |
| 6 | Con el TPV abierto, **desconectar el cable de red** (en la VM: *Dispositivos → Red → Conectar cable* desmarcado). Hacer una venta. Volver a conectar | La venta se guarda sin red (aviso de «sin conexión») y aparece en *Punto de venta → Pedidos* en el PC del gerente al volver la red | `evidencias/06-tpv-sin-red.png` (el aviso) y `evidencias/06-pedido-sincronizado.png` (el pedido en el backend) |

Si la prueba 6 falla (la venta no se guarda sin red), mirar en Edge del TPV, fuera del quiosco, `edge://serviceworker-internals`: tiene que haber un *service worker* registrado para `https://192.168.10.10`. Sin HTTPS válido no se registra.

## 6. PC del gerente

- **Windows:** doble clic en `odoo.crt` → *Instalar certificado* → *Equipo local* → *Colocar todos los certificados en el siguiente almacén* → *Entidades de certificación raíz de confianza*.
- **Ubuntu:**
  ```bash
  sudo cp odoo.crt /usr/local/share/ca-certificates/odoo-almichain.crt && sudo update-ca-certificates
  ```
  Firefox no usa el almacén del sistema: *Ajustes → Privacidad y seguridad → Certificados → Ver certificados → Autoridades → Importar*.
- Abrir `https://192.168.10.10` y comprobar que no hay aviso y que la huella coincide con la del paso 2. **Captura:** `evidencias/07-gerente-https.png`.
- Los scripts de las tareas 35 y 36 desde el PC del gerente: `ODOO_URL=https://192.168.10.10`. Python usa el almacén de Ubuntu, así que vale con el `update-ca-certificates` de arriba. En el propio servidor siguen funcionando con `http://localhost:8069`.

## 7. Cerrar

- [ ] Pruebas 5 y 6 en la tabla de la sección 4 de [DOCUMENTACION.md](DOCUMENTACION.md), con sus evidencias.
- [ ] Huella del servidor del equipo apuntada en DOCUMENTACION.md (sección 4) en lugar de la de la VM.
- [ ] Backlog: tarea 52 a «Hecho»; en la tarea 46, S-02 y S-14 cerrados.
- [ ] Comprobaciones 2 y 3 de la [tarea 46, sección 5](../../seguridad/46-revision-seguridad/DOCUMENTACION.md#5-comprobaciones-manuales-capturas) (nmap al servidor y certificado en el TPV): se hacen ya aquí.
