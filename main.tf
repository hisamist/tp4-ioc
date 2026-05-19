terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "docker" {}

# ========== RESEAU ==========
resource "docker_network" "app_network" {
  name = "${var.project_name}-network"
}

# ========== VOLUMES ==========
resource "docker_volume" "pgdata" {
  name = "${var.project_name}-pgdata"
}

# ========== MODULES ==========
module "postgres" {
  source = "./modules/docker-service"

  name          = "${var.project_name}-db"
  image         = "postgres:16-alpine"
  internal_port = 5432
  external_port = 5432
  network_id    = docker_network.app_network.id
  env = [
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}"
  ]
  volumes = [{
    volume_name    = docker_volume.pgdata.name
    container_path = "/var/lib/postgresql/data"
  }]
}

module "redis" {
  source = "./modules/docker-service"

  name          = "${var.project_name}-redis"
  image         = "redis:7-alpine"
  internal_port = 6379
  external_port = 6379
  network_id    = docker_network.app_network.id
}

module "app" {
  source = "./modules/docker-service"

  name          = "${var.project_name}-app"
  image         = "nginx:alpine"
  internal_port = 80
  external_port = var.app_port
  network_id    = docker_network.app_network.id
}
