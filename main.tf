terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "docker" {
  # Utilise le socket Docker local par defaut
  # Sur Windows avec Docker Desktop : rien a configurer
  # Sur Linux : host = "unix:///var/run/docker.sock"
}

module "docker_service" {
  source = "./modules/docker-service"

  project_name      = var.project_name
  postgres_password = var.postgres_password
  postgres_db       = var.postgres_db
  app_port          = var.app_port
}