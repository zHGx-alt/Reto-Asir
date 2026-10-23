# Tarea 30: Hosting de la web en AWS con dominio y HTTPS

- **Bloque:** 6 Web
- **Depende de:** tarea 28 (web implementada)
- **Responsable:** Adrian · **Revisa:** Eneko.P
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** borrador; falta montarlo y probarlo
- **Fecha:** 23/10/2026

## 1. Alcance

El enunciado pide que la web se sirva **por HTTPS, con dominio propio, alojada en la nube y con un despliegue reproducible**. Este documento explica cómo se aloja en AWS y cómo se comprueba. La automatización con Terraform y GitHub Actions es la tarea 31; la sección 9 indica qué recursos tiene que crear.

## 2. Arquitectura elegida

```
                                   EC2 (Ubuntu 24.04, IP elástica)
Navegador ──HTTPS──▶ almichain.duckdns.org ──▶ nginx + certificado Let's Encrypt
                                                 ▲
                                                 │ aws s3 sync cada 5 min (rol LabInstanceProfile)
                                                 │
                    aws s3 sync web/ ──▶ Bucket S3 privado (index.html, style.css, script.js)
```

| Pieza | Para qué |
|---|---|
| **Bucket S3** | Guarda la versión publicada de la web. Es **privado**: solo lo leen la EC2 (por su rol) y el equipo (con sus credenciales). |
| **EC2 + nginx** | Sirve la web por HTTPS y redirige HTTP a HTTPS. Cada 5 minutos descarga del bucket los cambios. |
| **IP elástica** | Fija la IP pública de la EC2: no cambia aunque la instancia se pare y se vuelva a arrancar. |
| **DuckDNS** | Dominio gratuito `almichain.duckdns.org`, con un registro A que apunta a la IP elástica. |
| **Let's Encrypt (certbot)** | Certificado TLS gratuito que se renueva solo. |

### Por qué no CloudFront

La primera idea era S3 + CloudFront + un certificado de ACM, sin ningún servidor. Se descartó por el dominio:

- Un dominio propio de pago no entra en el presupuesto del reto, y las alternativas gratuitas (GitHub Student Pack, eu.org) tardan días en aprobarse.
- DuckDNS es gratuito e inmediato, pero solo admite registros A, AAAA y TXT. CloudFront necesita un CNAME porque no tiene IP fija, y ACM valida los certificados también con un CNAME.

Con una EC2 con IP elástica basta un registro A, y Let's Encrypt sí emite certificados para subdominios de DuckDNS.

## 3. Requisitos previos

| Requisito | Valor |
|---|---|
| Cuenta de AWS | AWS Academy Learner Lab (50 $ de crédito) |
| Región | `us-east-1` (N. Virginia) |
| Dominio | `almichain.duckdns.org` (cuenta gratuita en [duckdns.org](https://www.duckdns.org)) |
| Herramientas | AWS CLI v2 y un cliente SSH en el equipo de trabajo |

En todo el documento, `<bucket>` es el nombre del bucket (por ejemplo `almi-chain-web-2026`; los nombres de bucket son únicos en todo AWS) y `<ip-elastica>` la IP pública fija de la EC2.

> **Learner Lab.** Las credenciales caducan al terminar cada sesión. Antes de usar la CLI en el equipo de trabajo, copiar las de **AWS Details → AWS CLI** en `~/.aws/credentials`. La clave SSH del laboratorio (`labsuser.pem`) se descarga desde ese mismo panel.

## 4. Procedimiento

### 4.1 Bucket S3

1. **S3 → Create bucket**, en la región `us-east-1`, con el nombre `<bucket>`.
2. Dejar marcado **Block all public access**: el bucket no se abre al público.
3. Desde la raíz del repositorio, subir la web (el `README.txt` no se publica):
   ```
   aws s3 sync web/ s3://<bucket>/ --delete --exclude "README.txt" --exclude ".gitkeep"
   ```

### 4.2 Grupo de seguridad

**EC2 → Security Groups → Create security group**, llamado `sg-web-almichain`:

| Tipo | Puerto | Origen | Motivo |
|---|---|---|---|
| HTTP | 80 | `0.0.0.0/0` | Redirección a HTTPS y validación de Let's Encrypt |
| HTTPS | 443 | `0.0.0.0/0` | La web |
| SSH | 22 | **My IP** | Administración, solo desde nuestra IP |

### 4.3 Instancia EC2

**EC2 → Launch instance**:

| Opción | Valor | Motivo |
|---|---|---|
| Nombre | `web-almichain` | |
| AMI | Ubuntu Server 24.04 LTS | Soporte largo y paquetes de nginx y certbot en los repositorios |
| Tipo | `t3.micro` | Basta para una web estática |
| Key pair | `vockey` | La clave del Learner Lab |
| Security group | `sg-web-almichain` | Sección 4.2 |
| IAM instance profile (*Advanced details*) | `LabInstanceProfile` | Da a la EC2 permiso para leer el bucket **sin guardar claves en ella** |

### 4.4 IP elástica

1. **EC2 → Elastic IPs → Allocate Elastic IP address**.
2. **Actions → Associate Elastic IP address** y elegir la instancia `web-almichain`.
3. Anotar la IP: es `<ip-elastica>`.

### 4.5 DuckDNS

1. Entrar en [duckdns.org](https://www.duckdns.org) con una cuenta de GitHub o Google.
2. Crear el subdominio `almichain`.
3. En el campo **current ip**, poner `<ip-elastica>` y pulsar **update ip**.
4. Comprobar que resuelve a la IP elástica:
   ```
   nslookup almichain.duckdns.org
   ```

> El **token** de DuckDNS permite cambiar la IP del dominio. No se sube al repositorio ni se pega en capturas.

### 4.6 Servidor web y certificado

Copiar el script de instalación a la EC2 y ejecutarlo:

```
scp -i labsuser.pem scripts/web/instalar-servidor-web.sh ubuntu@<ip-elastica>:
```
```
ssh -i labsuser.pem ubuntu@<ip-elastica>
```
```
sudo BUCKET=<bucket> DOMINIO=almichain.duckdns.org EMAIL=<correo> ./instalar-servidor-web.sh
```

El script [`scripts/web/instalar-servidor-web.sh`](../../scripts/web/instalar-servidor-web.sh) hace lo siguiente:

1. Instala nginx, certbot y la AWS CLI.
2. Descarga la web del bucket a `/var/www/almichain`. Crea `/usr/local/bin/actualizar-web` y una tarea de cron que la vuelve a descargar cada 5 minutos.
3. Configura nginx para `almichain.duckdns.org`. Oculta la versión del servidor (`server_tokens off`) y añade las cabeceras de seguridad: HSTS, `X-Content-Type-Options`, `X-Frame-Options` y `Referrer-Policy`.
4. Pide el certificado a Let's Encrypt con certbot, que también configura la redirección de HTTP a HTTPS. Certbot deja programada la renovación automática (`certbot.timer`).

El correo solo lo usa Let's Encrypt para avisar si un certificado va a caducar sin renovarse.

## 5. Pruebas

| Prueba | Comando o acción | Resultado esperado |
|---|---|---|
| HTTP redirige a HTTPS | `curl -I http://almichain.duckdns.org` | `301` con `Location: https://almichain.duckdns.org/` |
| HTTPS funciona | `curl -I https://almichain.duckdns.org` | `200` y la cabecera `strict-transport-security` |
| Certificado válido | Abrir la web y pulsar el candado | Emitido por Let's Encrypt para `almichain.duckdns.org` |
| Renovación automática | En la EC2: `sudo certbot renew --dry-run` | `Congratulations, all simulated renewals succeeded` |
| Bucket privado | `curl -I https://<bucket>.s3.us-east-1.amazonaws.com/index.html` | `403 Forbidden` |
| Versión del servidor oculta | Cabecera `server` de `curl -I` | `nginx`, sin número de versión |
| Geolocalización | Pulsar «Usar mi ubicación» | El navegador pide permiso; solo funciona con HTTPS |
| Mapa y slideshow | Navegar por la web | El mapa de OpenStreetMap carga y el carrusel cambia de plato |
| Despliegue desde S3 | Cambiar un texto, subirlo con `aws s3 sync` y esperar 5 minutos | El cambio aparece en la web |

Guardar capturas de cada prueba en `docs/evidencias/30-hosting-aws/`. La validación W3C, Lighthouse y la accesibilidad son la tarea 29.

## 6. Actualizar la web

Basta con subir los cambios al bucket desde el equipo de trabajo:

```
aws s3 sync web/ s3://<bucket>/ --delete --exclude "README.txt" --exclude ".gitkeep"
```

En menos de 5 minutos, la EC2 los descarga sola. Para publicarlos al momento, ejecutar en la EC2:

```
sudo actualizar-web
```

## 7. Seguridad

- El bucket es privado y tiene activado *Block all public access*. La EC2 lo lee con el rol del laboratorio, sin claves guardadas en la máquina.
- Todo el tráfico va por HTTPS. HSTS hace que el navegador no vuelva a intentarlo por HTTP.
- SSH solo está abierto a nuestra IP. Los puertos 80 y 443 son los únicos públicos.
- El token de DuckDNS y las credenciales del Learner Lab no se suben al repositorio.

## 8. Limitaciones y coste

- **El Learner Lab para las instancias al acabar cada sesión**, así que la web solo está en línea mientras el laboratorio está arrancado. Al volver a pulsar **Start Lab**, la EC2 arranca, nginx se inicia solo y la IP elástica sigue siendo la misma, de modo que no hay que tocar DuckDNS. En producción habría que usar una cuenta de AWS normal.
- **Coste aproximado:** la `t3.micro` cuesta en torno a 0,01 $ por hora encendida. La IP elástica cuesta unos 0,005 $ por hora, también con la instancia parada: unos 3,6 $ al mes. El bucket cuesta céntimos. Para un mes de reto sale bastante por debajo de los 50 $ del laboratorio. Al terminar el reto, **liberar la IP elástica** para que deje de cobrarse.
- **El dominio es un subdominio de `duckdns.org`.** Si más adelante se consigue un dominio propio, basta con crearle un registro A hacia `<ip-elastica>` y volver a ejecutar certbot con el nuevo nombre.

## 9. Para la tarea 31 (Terraform)

Recursos que tiene que crear la infraestructura como código para reproducir este montaje:

| Recurso de Terraform | Sección |
|---|---|
| `aws_s3_bucket` + `aws_s3_bucket_public_access_block` | 4.1 |
| `aws_security_group` | 4.2 |
| `aws_instance`, con `iam_instance_profile = "LabInstanceProfile"` y el script de la sección 4.6 como `user_data` | 4.3 y 4.6 |
| `aws_eip` + `aws_eip_association` | 4.4 |

DuckDNS queda fuera de Terraform. La IP se puede actualizar desde el `user_data` con una petición a la API de DuckDNS, pasando el token como secreto y nunca escrito en el código. El despliegue del contenido (sección 6) va en GitHub Actions con `aws s3 sync`.
