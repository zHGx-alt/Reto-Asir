# Tarea 31 · Infraestructura como código de la web (el montaje manual está en docs/web/30-hosting-aws.md)
terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Las credenciales NO van aquí: se toman del entorno (~/.aws/credentials o variables AWS_*),
# copiadas de "AWS Details → AWS CLI" del Learner Lab. Caducan al cerrar la sesión del laboratorio.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Proyecto = "Almi-Chain"
      Tarea    = "31"
      Gestion  = "terraform"
    }
  }
}
