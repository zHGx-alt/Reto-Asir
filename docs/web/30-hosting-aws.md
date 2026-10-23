# Tarea 30: Hosting de la web en AWS con dominio propio y HTTPS

- **Bloque:** 6 Web
- **Depende de:** tarea 28 (web implementada)
- **Responsable:** Adrian · **Revisa:** Eneko.P
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** borrador; falta montarlo y probarlo
- **Fecha:** 23/10/2026

## 1. Alcance

El enunciado pide que la web se sirva **por HTTPS, con dominio propio, alojada en la nube y con un despliegue reproducible**. Este documento explica cómo se aloja en AWS y cómo se comprueba. La automatización con Terraform y GitHub Actions es la tarea 31; la sección 9 indica qué recursos tiene que crear.

## 2. Arquitectura elegida

La web es estática: el formulario no envía datos (tarea 27). Por eso no hace falta ningún servidor.

```
Navegador ──HTTPS──▶ CloudFront ──(OAC)──▶ Bucket S3 privado
                     certificado ACM       index.html, style.css, script.js
                     www.<dominio>
```

| Servicio | Para qué |
|---|---|
| **S3** | Guarda los archivos de la web. El bucket es **privado**: nadie puede leerlo directamente. |
| **CloudFront** | Sirve la web por HTTPS desde ubicaciones cercanas al visitante y redirige HTTP a HTTPS. Es el único que puede leer el bucket, mediante *Origin Access Control* (OAC). |
| **ACM** | Emite el certificado TLS del dominio, gratis y con renovación automática. |
| **DNS del dominio** | Apunta `www.<dominio>` a CloudFront. |

Se ha descartado una máquina EC2 con nginx porque habría que mantener el sistema, abrir puertos y renovar el certificado. Además, la web se caería cada vez que se parase el laboratorio.

## 3. Requisitos previos

| Requisito | Valor |
|---|---|
| Cuenta de AWS | AWS Academy Learner Lab (50 $ de crédito) |
| Región | `us-east-1`: es obligatoria para el certificado de CloudFront y es una de las que permite el Learner Lab |
| Dominio | `<dominio>` (pendiente; ver nota) |
| Herramientas | AWS CLI v2 en el equipo desde el que se sube la web |

> **Dominio.** Se puede conseguir gratis con el GitHub Student Pack (`.me` o `.tech` durante un año) o comprar uno barato. El Learner Lab no permite registrar dominios en Route 53, así que el DNS se gestiona en el registrador.

> **Learner Lab.** Las credenciales caducan al terminar cada sesión. Antes de usar la CLI, copiar las de **AWS Details → AWS CLI** en `~/.aws/credentials`. Antes de empezar, comprobar que el laboratorio deja usar CloudFront y Certificate Manager.

## 4. Procedimiento

En todo el documento, `<dominio>` es el dominio comprado (por ejemplo `almichain.me`) y `<bucket>` el nombre del bucket (por ejemplo `almi-chain-web-2026`). Los nombres de bucket son únicos en todo AWS.

### 4.1 Certificado (ACM)

El certificado se pide primero porque tarda en validarse.

1. En la consola, cambiar a la región **N. Virginia (`us-east-1`)**. CloudFront solo acepta certificados de esa región.
2. **Certificate Manager → Request → Request a public certificate**.
3. Nombres: `www.<dominio>` y `<dominio>`.
4. Validación: **DNS validation**.
5. ACM muestra un registro CNAME por cada nombre. Crearlos en el panel DNS del registrador, copiando nombre y valor tal cual.
6. Esperar a que el estado pase a **Issued**. Suele tardar unos minutos y puede llegar a una hora.

### 4.2 Bucket S3

1. **S3 → Create bucket**, en la región `us-east-1`, con el nombre `<bucket>`.
2. Dejar marcado **Block all public access**. El bucket no se abre al público: solo lo leerá CloudFront.
3. **No** activar *Static website hosting*: con OAC, CloudFront lee el bucket por su punto de acceso normal.
4. Subir la web desde la raíz del repositorio (el `README.txt` no se publica):
   ```
   aws s3 sync web/ s3://<bucket>/ --delete --exclude "README.txt" --exclude ".gitkeep"
   ```

### 4.3 Distribución de CloudFront

**CloudFront → Create distribution**:

| Opción | Valor | Motivo |
|---|---|---|
| Origin domain | `<bucket>.s3.us-east-1.amazonaws.com` (el bucket, no el endpoint *website*) | Necesario para usar OAC |
| Origin access | **Origin access control settings** → *Create new OAC* | Solo CloudFront puede leer el bucket |
| Viewer protocol policy | **Redirect HTTP to HTTPS** | Todo el tráfico va cifrado |
| Allowed HTTP methods | GET, HEAD | La web solo se lee |
| Cache policy | `CachingOptimized` | Política gestionada recomendada para contenido estático |
| Response headers policy | `SecurityHeadersPolicy` | Añade HSTS, `X-Content-Type-Options`, `X-Frame-Options` y `Referrer-Policy` |
| Web Application Firewall | No activar | No hace falta en una web estática y tiene coste |
| Price class | Solo Norteamérica y Europa | Más barato; los visitantes están en Bilbao |
| Alternate domain names (CNAME) | `www.<dominio>` y `<dominio>` | Dominio propio |
| Custom SSL certificate | El de la sección 4.1 | HTTPS con el dominio propio |
| Security policy | `TLSv1.2_2021` (recomendada) | Solo TLS 1.2 o superior |
| Default root object | `index.html` | Lo que se sirve al pedir `/` |

Al crearla, CloudFront avisa de que hay que actualizar la política del bucket. Pulsar **Copy policy** y pegarla en **S3 → `<bucket>` → Permissions → Bucket policy**. Debe quedar así:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipalReadOnly",
      "Effect": "Allow",
      "Principal": { "Service": "cloudfront.amazonaws.com" },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::<bucket>/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::<id-cuenta>:distribution/<id-distribucion>"
        }
      }
    }
  ]
}
```

La condición `AWS:SourceArn` limita el acceso a esta distribución: ni siquiera otra distribución de CloudFront puede leer el bucket.

La distribución tarda unos minutos en desplegarse. Al terminar, anotar su dominio, del tipo `dxxxxxxxxxxxx.cloudfront.net`.

### 4.4 DNS

En el panel DNS del registrador:

| Tipo | Nombre | Valor |
|---|---|---|
| CNAME | `www` | `dxxxxxxxxxxxx.cloudfront.net` |
| ALIAS / ANAME, o redirección | `@` (dominio raíz) | Si el registrador admite ALIAS o ANAME, apuntarlo a `dxxxxxxxxxxxx.cloudfront.net`. Si no, crear una **redirección 301** a `https://www.<dominio>`. |

El dominio raíz no admite CNAME. Por eso la dirección principal de la web es `www.<dominio>`.

## 5. Pruebas

| Prueba | Comando o acción | Resultado esperado |
|---|---|---|
| HTTP redirige a HTTPS | `curl -I http://www.<dominio>` | `301` con `Location: https://www.<dominio>/` |
| HTTPS funciona | `curl -I https://www.<dominio>` | `200` y la cabecera `strict-transport-security` |
| Certificado válido | Abrir la web y pulsar el candado | Emitido por Amazon para `www.<dominio>` |
| Bucket privado | `curl -I https://<bucket>.s3.us-east-1.amazonaws.com/index.html` | `403 Forbidden` |
| Geolocalización | Pulsar «Usar mi ubicación» | El navegador pide permiso; solo funciona con HTTPS |
| Mapa y slideshow | Navegar por la web | El mapa de OpenStreetMap carga y el carrusel cambia de plato |

Guardar capturas de cada prueba en `docs/evidencias/30-hosting-aws/`. La validación W3C, Lighthouse y la accesibilidad son la tarea 29.

## 6. Actualizar la web

Cada vez que cambie algo en `web/`, hay que subir los cambios y vaciar la caché de CloudFront:

```
aws s3 sync web/ s3://<bucket>/ --delete --exclude "README.txt" --exclude ".gitkeep"
```
```
aws cloudfront create-invalidation --distribution-id <id-distribucion> --paths "/*"
```

Sin la invalidación, CloudFront puede seguir sirviendo la versión anterior hasta que caduque su caché. La tarea 31 automatiza estos dos pasos con GitHub Actions.

## 7. Seguridad

- El bucket es privado y tiene activado *Block all public access*; solo esta distribución puede leerlo.
- Todo el tráfico va por HTTPS, con TLS 1.2 o superior, y HSTS hace que el navegador no vuelva a intentarlo por HTTP.
- El certificado de ACM se renueva solo mientras los CNAME de validación sigan en el DNS. **No borrarlos.**
- No se suben claves de AWS al repositorio. Las credenciales del Learner Lab se quedan en `~/.aws/credentials` del equipo de cada uno.

## 8. Coste estimado

Con el tráfico de una web académica, el coste es de céntimos al mes: unos pocos MB en S3 y CloudFront dentro de la capa gratuita. El certificado de ACM es gratuito. El único gasto real es el dominio, si no se consigue gratis.

## 9. Para la tarea 31 (Terraform)

Recursos que tiene que crear la infraestructura como código para reproducir este montaje:

| Recurso de Terraform | Sección |
|---|---|
| `aws_acm_certificate` + `aws_acm_certificate_validation` (proveedor en `us-east-1`) | 4.1 |
| `aws_s3_bucket` + `aws_s3_bucket_public_access_block` | 4.2 |
| `aws_cloudfront_origin_access_control` | 4.3 |
| `aws_cloudfront_distribution` | 4.3 |
| `aws_s3_bucket_policy` | 4.3 |

Los registros DNS quedan fuera de Terraform porque están en el registrador. El despliegue del contenido (sección 6) va en GitHub Actions.
