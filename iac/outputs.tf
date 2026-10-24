output "ip_elastica" {
  description = "IP pública fija de la web (registro A de DuckDNS)"
  value       = aws_eip.web.public_ip
}

output "url" {
  description = "Dirección de la web"
  value       = "https://${var.dominio}"
}

output "ssh" {
  description = "Cómo entrar en la instancia"
  value       = "ssh -i labsuser.pem ubuntu@${aws_eip.web.public_ip}"
}

output "bucket" {
  description = "Bucket privado con la web (lo usa desplegar-web.yml)"
  value       = aws_s3_bucket.web.id
}
