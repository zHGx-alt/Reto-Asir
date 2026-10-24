# Recursos de la tabla de la sección 9 de docs/web/30-hosting-aws.md.

locals {
  carpeta_web = "${path.module}/../web"
  # Lo que se publica: todo web/ salvo las notas del equipo
  ficheros_web = setsubtract(fileset(local.carpeta_web, "**"), ["README.txt", ".gitkeep"])
  tipos = {
    html = "text/html; charset=utf-8"
    css  = "text/css; charset=utf-8"
    js   = "application/javascript; charset=utf-8"
    svg  = "image/svg+xml"
    png  = "image/png"
    jpg  = "image/jpeg"
    webp = "image/webp"
    ico  = "image/x-icon"
  }
}

# ---- 4.1 Bucket S3 privado ---------------------------------------------------
resource "aws_s3_bucket" "web" {
  bucket = var.bucket
}

resource "aws_s3_bucket_public_access_block" "web" {
  bucket                  = aws_s3_bucket.web.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "web" {
  bucket = aws_s3_bucket.web.id
  rule {
    object_ownership = "BucketOwnerEnforced" # ACL deshabilitadas
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web" {
  bucket = aws_s3_bucket.web.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Primera carga del contenido. Los cambios posteriores los publica GitHub Actions (desplegar-web.yml).
resource "aws_s3_object" "web" {
  for_each     = local.ficheros_web
  bucket       = aws_s3_bucket.web.id
  key          = each.value
  source       = "${local.carpeta_web}/${each.value}"
  etag         = filemd5("${local.carpeta_web}/${each.value}")
  content_type = lookup(local.tipos, lower(element(split(".", each.value), length(split(".", each.value)) - 1)), "application/octet-stream")
}

# ---- 4.2 Grupo de seguridad ----------------------------------------------------
resource "aws_security_group" "web" {
  name        = "web-almichain-sg"
  description = "Web Almi Chain: HTTP, HTTPS y SSH"

  ingress {
    description = "HTTP (redireccion a HTTPS y validacion de Lets Encrypt)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH solo desde nuestra IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }
  egress {
    description = "Salida (paquetes, S3 y Lets Encrypt)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---- 4.3 Instancia EC2 con Ubuntu 24.04 ------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ---- 4.4 IP elástica (se crea antes que la instancia para pasarla al user_data) ----
resource "aws_eip" "web" {
  domain = "vpc"
  tags   = { Name = "web-almichain" }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.tipo_instancia
  key_name               = var.clave_ssh
  iam_instance_profile   = var.perfil_instancia
  vpc_security_group_ids = [aws_security_group.web.id]

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  # 4.5 y 4.6: espera a tener la IP elástica, actualiza DuckDNS (si hay token) y ejecuta el script de la tarea 30
  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    ip_elastica   = aws_eip.web.public_ip
    dominio       = var.dominio
    duckdns_token = var.duckdns_token
    bucket        = aws_s3_bucket.web.id
    region        = var.region
    email         = var.email
    script        = file("${path.module}/../scripts/web/instalar-servidor-web.sh")
  })
  user_data_replace_on_change = true

  tags = { Name = "web-almichain" }

  depends_on = [aws_s3_object.web]
}

resource "aws_eip_association" "web" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web.id
}
