# Tarea 33 · Instalar Odoo + PostgreSQL con Docker

**Responsable:** Iker · **Revisa:** Peio · **Fecha de ejecución:** 22/10/2026 · **Depende de:** 32 (elección del ERP)
**Estado:** ✅ Hecha en máquina virtual

> La tarea 32 (comparativa y elección del ERP, de Eneko.S) está cerrada y eligió **Odoo Community**, el ERP instalado aquí.

## 1. Resultado
Odoo **19.0** funcionando en Docker con **PostgreSQL 17**. La base de datos `tienda` está en español, sin datos de demostración
y con la contraseña de admin cambiada.

![Login de Odoo](evidencias/odoo-login.jpg)

## 2. Arquitectura

```
                ServidorERP (Debian 13, Docker 26.1, Compose 2.26)
 ┌───────────────────────────────────────────────────────────────┐
 │  red Docker "interna"                                         │
 │  ┌────────────────────┐   5432    ┌────────────────────────┐  │
 │  │ odoo:19.0          │──────────▶│ postgres:17            │  │
 │  │ volumen odoo-web-  │           │ volumen odoo-db-data   │  │
 │  │ data (adjuntos)    │           │ (sin puerto publicado) │  │
 │  └─────────┬──────────┘           └────────────────────────┘  │
 └────────────┼──────────────────────────────────────────────────┘
              │ 8069 (HTTP)
        TPV / gerente (navegador)
```

| Elemento | Valor |
|---|---|
| Máquina virtual | `ServidorERP`: 2 CPU, 4 GB de RAM, disco de 30 GB. Reenvío de puertos `127.0.0.1:2223 → 22` y `127.0.0.1:8069 → 8069` |
| Sistema operativo | Debian 13.7, instalado sin intervención con [`preseed-servidor.cfg`](preseed-servidor.cfg) (el mismo método que la tarea 16) |
| Docker | `docker.io` 26.1.5 + `docker-compose` 2.26.1, de los repositorios oficiales de Debian |
| Imágenes | `odoo:19.0` (19.0-20261015) y `postgres:17` |
| Volúmenes | `odoo-db-data` (base de datos) y `odoo-web-data` (adjuntos). **Son lo que hay que copiar en el backup (tarea 44).** |
| Recursos en marcha | 703 MB de RAM usados y 4,5 GB de disco |

## 3. Archivos

| Archivo | Para qué sirve | ¿Al repo? |
|---|---|---|
| [`odoo/docker-compose.yml`](odoo/docker-compose.yml) | Los servicios `db` y `odoo`, la red interna y los volúmenes | ✅ |
| [`odoo/.env.example`](odoo/.env.example) | Plantilla de las variables, sin secretos reales | ✅ |
| [`odoo/.gitignore`](odoo/.gitignore) | Evita subir `.env` y `odoo.conf` | ✅ |
| [`odoo/desplegar-odoo.sh`](odoo/desplegar-odoo.sh) | Instala Docker, genera los secretos, crea la base de datos y arranca Odoo. Idempotente. | ✅ |
| `/opt/odoo/.env` (en el servidor) | Contraseñas reales, generadas al azar | ❌ **nunca** |
| `/opt/odoo/config/odoo.conf` (en el servidor) | Configuración con la contraseña maestra | ❌ **nunca** |

## 4. Pasos

### 4.1 Instalar el servidor
```bash
VBoxManage createvm --name ServidorERP --ostype Debian_64 --register
VBoxManage modifyvm ServidorERP --memory 4096 --cpus 2 --nic1 nat \
  --natpf1 "ssh,tcp,127.0.0.1,2223,,22" --natpf1 "odoo,tcp,127.0.0.1,8069,,8069"
# disco de 30 GB + unidad de DVD, igual que en la tarea 16
VBoxManage unattended install ServidorERP --iso=debian-13.7.0-amd64-netinst.iso \
  --user=tecnico --password-file=... --script-template=preseed-servidor.cfg --start-vm=headless
```
Instalado en 4 min 18 s.

### 4.2 Desplegar Odoo
```bash
scp -P 2223 odoo/docker-compose.yml odoo/desplegar-odoo.sh tecnico@127.0.0.1:odoo/
ssh -p 2223 tecnico@127.0.0.1 'sudo bash odoo/desplegar-odoo.sh'
```
Lo que hace el script (log completo en [`evidencias/salida-desplegar-odoo.log`](evidencias/salida-desplegar-odoo.log)):
1. Instala Docker y Compose desde Debian.
2. Copia el proyecto a `/opt/odoo` (permisos `750`, propietario root).
3. Genera `.env` con contraseñas aleatorias de 24 caracteres (permisos `600`) y `odoo.conf`.
4. Descarga las imágenes y arranca PostgreSQL. Espera a que su *healthcheck* diga `healthy`.
5. Crea la base de datos `tienda`: `-i base --without-demo=all --load-language=es_ES`. Después **cambia la contraseña por defecto `admin/admin`** con `odoo shell`.
6. Arranca Odoo y espera a que `/web/login` responda.

### 4.3 Acceso
- Desde el PC anfitrión: <http://localhost:8069>
- Usuario: `admin`
- Contraseña: en el servidor, con `sudo grep ODOO_ADMIN /opt/odoo/.env`

## 5. Seguridad por defecto

| Medida | Cómo |
|---|---|
| Sin contraseñas por defecto | `admin/admin` cambiada por una aleatoria (comprobado: el login con `admin/admin` se rechaza) |
| Secretos fuera del repositorio | `.env` y `odoo.conf` generados en el servidor, con permisos `600`/`750`, y en `.gitignore`. En el repo solo va `.env.example`. |
| PostgreSQL no expuesto | Sin `ports:` en `docker-compose.yml`: solo es accesible desde la red Docker `interna` (comprobado: el puerto 5432 está cerrado en el servidor) |
| Gestor web de bases de datos desactivado | `list_db = False`: no se pueden crear, copiar, borrar ni descargar bases de datos desde el navegador (comprobado: `Access Denied`) |
| Solo la base de la tienda | `dbfilter = ^tienda$` |
| Mínimos privilegios | `tecnico` **no** está en el grupo `docker`, porque ese grupo equivale a ser root. Docker se maneja con `sudo`. |
| Reinicio automático | `restart: unless-stopped` en los dos contenedores |
| Cortafuegos del servidor | [`cortafuegos-servidor.sh`](cortafuegos-servidor.sh) (`ufw`): entrada bloqueada; SSH solo desde el PC del gerente; 80/443 solo desde la LAN. Hace falta porque la red del local es plana ([tarea 23, apartado 5.2](../../redes/23-plano-direccionamiento.md#52-decisión-red-plana-con-red-de-invitados-aislada-24102026)). Pendiente de ejecutar en la VM |

**Comunicaciones cifradas:** Odoo responde por **HTTP**. El proxy HTTPS está preparado en la [tarea 52](../52-https-odoo/DOCUMENTACION.md) (nginx delante y Odoo solo en `127.0.0.1:8069`); falta activarlo.

## 6. Pruebas
De [`evidencias/pruebas-odoo.txt`](evidencias/pruebas-odoo.txt):

| # | Prueba | Resultado |
|---|---|---|
| 1 | `GET /web/login` | ✅ HTTP 200, formulario en español |
| 2 | Versión por JSON-RPC | ✅ `19.0-20261015` |
| 3 | Login `admin` con la contraseña del `.env` | ✅ uid 2 |
| 4 | Login `admin/admin` | ✅ Rechazado |
| 5 | `/web/database/manager` | ✅ "database manager has been disabled by the administrator" |
| 6 | Listar bases de datos por JSON-RPC | ✅ `Access Denied` |
| 7 | Puerto 5432 en el servidor | ✅ Cerrado |
| 8 | Permisos de `/opt/odoo` y `.env` | ✅ `750 root` / `600 root` |
| 9 | `tecnico` en el grupo `docker` | ✅ No |

## 7. Incidencias

| # | Incidencia | Causa | Solución |
|---|---|---|---|
| 1 | `docker: orden no encontrada` justo después de instalar `docker.io` | En Debian 13 el cliente `docker` va en el paquete `docker-cli`, que solo es "recomendado", y se instaló con `--no-install-recommends` | Añadir `docker-cli` a la lista de paquetes |
| 2 | Duda sobre usar `workers = 2` (multiproceso) | Con workers, el chat y las notificaciones en tiempo real (`/websocket`) necesitan un proxy que los envíe al puerto 8072 | `workers = 0` (multihilo), que basta para una tienda pequeña. Cuando esté el proxy HTTPS se puede pasar a workers. |

## 8. Para las siguientes tareas
- **34 · Configurar módulos (Iker):** entrar en <http://localhost:8069> como `admin` e instalar Ventas, Punto de Venta, Inventario y Facturación.
- **36 · Importar/exportar datos (Iker):** con `list_db = False` no se puede usar el gestor web de bases de datos. Para copias completas hay que usar `pg_dump` (tarea 44).
- **44 · Backup (Iker):** hay que copiar los volúmenes `odoo-db-data` (`pg_dump` del contenedor `db`) y `odoo-web-data`, además de `/opt/odoo/.env`, **cifrados**.

## 9. Pendiente
- [ ] Revisión de Peio → mover a **Hecho** en el Kanban.
- [ ] Ejecutar `sudo ./cortafuegos-servidor.sh` en `ServidorERP` y guardar la salida de `ufw status verbose` como evidencia.
- [x] Confirmar con Eneko.S (tarea 32) que el ERP elegido es Odoo.
