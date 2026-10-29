# Tarea 31 · Infraestructura como código de la web

- **Responsable:** Adrian (desde el 29/10; antes Iker y Eneko.P)
- **Estado (24/10/2026):** Terraform escrito y comprobado con `terraform validate` y `terraform fmt -check` (Terraform 1.16, proveedor AWS 5.x); el `user_data` generado pasa `bash -n` con y sin token de DuckDNS. **Falta ejecutar `terraform apply` en el Learner Lab** (sección 4).

Crea con un solo comando el mismo montaje que la [tarea 30](../docs/web/30-hosting-aws.md) hizo a mano, y GitHub Actions publica la web cada vez que cambia `web/` en `main`.

## 1. Qué crea

| Fichero | Recursos | Tarea 30 |
|---|---|---|
| [`main.tf`](main.tf) | Bucket S3 privado (bloqueo de acceso público, ACL deshabilitadas, cifrado SSE-S3) y los ficheros de `web/` | 4.1 |
| | Grupo de seguridad `web-almichain-sg`: 80 y 443 abiertos, 22 solo desde `ssh_cidr` | 4.2 |
| | EC2 `t3.micro` con Ubuntu 24.04 (la AMI más reciente de Canonical), IMDSv2 obligatorio, disco cifrado, `LabInstanceProfile` | 4.3 |
| | IP elástica y su asociación | 4.4 |
| [`user-data.sh.tftpl`](user-data.sh.tftpl) | Primer arranque: espera a la IP elástica, actualiza DuckDNS (si se pasa el token), espera al DNS y ejecuta [`instalar-servidor-web.sh`](../scripts/web/instalar-servidor-web.sh) | 4.5 y 4.6 |
| [`variables.tf`](variables.tf), [`outputs.tf`](outputs.tf), [`versions.tf`](versions.tf) | Parámetros, salidas (IP, URL, SSH) y versiones | — |
| [`../.github/workflows/desplegar-web.yml`](../.github/workflows/desplegar-web.yml) | Valida Terraform y publica `web/` en el bucket con `aws s3 sync` | 6 |

## 2. Requisitos

- Terraform 1.6 o posterior (`winget install Hashicorp.Terraform` o `sudo snap install terraform --classic`).
- Credenciales del Learner Lab: **AWS Details → AWS CLI**, copiadas en `~/.aws/credentials`. Caducan al cerrar el laboratorio.
- Si se va a crear desde cero: **borrar antes el montaje manual** (instancia, IP elástica, grupo de seguridad y bucket) o cambiar el nombre del bucket, porque los nombres coinciden.

## 3. Secretos

- **Ninguno en el repositorio.** El correo y la IP de SSH van en `terraform.tfvars` (en `.gitignore`; plantilla en [`terraform.tfvars.example`](terraform.tfvars.example)).
- El **token de DuckDNS** se pasa por variable de entorno (`TF_VAR_duckdns_token`), sacado de KeePassXC. Aviso: va dentro del `user_data` de la instancia, que pueden leer quienes tengan acceso a la consola de EC2 de la cuenta. Si no se quiere, se deja vacío y la IP se pone a mano en duckdns.org (tarea 30, 4.5).
- El **estado de Terraform** (`terraform.tfstate`) se queda en el equipo de quien lo ejecuta (en `.gitignore`): contiene datos de la infraestructura.

## 4. Uso

```bash
cd iac
cp terraform.tfvars.example terraform.tfvars    # rellenar email y ssh_cidr
export TF_VAR_duckdns_token='...'               # opcional
terraform init
terraform plan
terraform apply
```

Al terminar muestra la IP elástica y la URL. La instancia tarda unos minutos más en tener el certificado: se sigue con `ssh -i labsuser.pem ubuntu@<ip> sudo tail -f /var/log/almichain-user-data.log`.

Comprobación (las mismas pruebas de la tarea 30, sección 5):

```bash
curl -I https://almichain1.duckdns.org
```

Para borrarlo todo al acabar el reto (y dejar de pagar la IP elástica): `terraform destroy`.

## 5. Publicación automática (GitHub Actions)

1. En GitHub: **Settings → Secrets and variables → Actions → New repository secret**, los tres valores de **AWS Details → AWS CLI**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` y `AWS_SESSION_TOKEN`.
2. Cada push a `main` que cambie `web/` ejecuta el workflow: valida Terraform y sube la web al bucket. La EC2 la descarga en menos de 5 minutos.
3. Las credenciales del Learner Lab **caducan** con cada sesión: antes de publicar hay que actualizar los tres secretos. Sin secretos, el workflow avisa y no falla.

## 6. Limitaciones del Learner Lab

- No deja crear roles de IAM: la instancia usa `LabInstanceProfile`, que tiene más permisos de los necesarios (tarea 30, sección 7). En una cuenta normal se crearía un rol con solo `s3:GetObject` y `s3:ListBucket` sobre el bucket.
- La instancia se para al cerrar el laboratorio; al volver a arrancarlo, la IP elástica sigue siendo la misma.
- Las credenciales temporales impiden un despliegue 100 % desatendido: hay que renovar los secretos de GitHub en cada sesión.
