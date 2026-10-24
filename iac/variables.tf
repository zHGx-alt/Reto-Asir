variable "region" {
  description = "Región de AWS (el Learner Lab solo deja us-east-1 y us-west-2)"
  type        = string
  default     = "us-east-1"
}

variable "bucket" {
  description = "Nombre del bucket S3 privado con la web (único en todo AWS)"
  type        = string
  default     = "almi-chain-web-2026"
}

variable "dominio" {
  description = "Dominio de la web (registro A de DuckDNS hacia la IP elástica)"
  type        = string
  default     = "almichain1.duckdns.org"
}

variable "email" {
  description = "Correo para los avisos de Let's Encrypt"
  type        = string
}

variable "ssh_cidr" {
  description = "Única red desde la que se permite SSH (nuestra IP pública con /32)"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "ssh_cidr tiene que ser una red concreta (por ejemplo 81.0.0.1/32), nunca 0.0.0.0/0."
  }
}

variable "duckdns_token" {
  description = "Token de DuckDNS para apuntar el dominio a la IP elástica. Vacío = se hace a mano (tarea 30, 4.5)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tipo_instancia" {
  description = "Tipo de la instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "clave_ssh" {
  description = "Par de claves de EC2 (en el Learner Lab, vockey)"
  type        = string
  default     = "vockey"
}

variable "perfil_instancia" {
  description = "Perfil de IAM de la instancia (el Learner Lab no deja crear roles: LabInstanceProfile)"
  type        = string
  default     = "LabInstanceProfile"
}
