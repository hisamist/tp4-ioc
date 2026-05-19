terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# ========== RESEAU ==========
resource "docker_network" "app_network" {
  name = "${var.project_name}-network"
}

# ========== IMAGES ==========
resource "docker_image" "postgres" {
  name         = "postgres:16-alpine"
  keep_locally = true
}

resource "docker_image" "redis" {
  name         = "redis:7-alpine"
  keep_locally = true
}

resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

# ========== VOLUMES ==========
resource "docker_volume" "pgdata" {
  name = "${var.project_name}-pgdata"
}

# ========== POSTGRESQL ==========
resource "docker_container" "postgres" {
  name  = "${var.project_name}-db"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}"
  ]

  volumes {
    volume_name    = docker_volume.pgdata.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.app_network.id
  }

  ports {
    internal = 5432
    external = 5432
  }

  restart = "unless-stopped"
}

# ========== REDIS ==========
resource "docker_container" "redis" {
  name  = "${var.project_name}-redis"
  image = docker_image.redis.image_id

  networks_advanced {
    name = docker_network.app_network.id
  }

  ports {
    internal = 6379
    external = 6379
  }

  restart = "unless-stopped"
}

# ========== APP (Nginx) ==========
resource "docker_container" "app" {
  name  = "${var.project_name}-app"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.app_network.id
  }

  ports {
    internal = 80
    external = var.app_port
  }

  depends_on = [
    docker_container.postgres,
    docker_container.redis
  ]

  restart = "unless-stopped"
}