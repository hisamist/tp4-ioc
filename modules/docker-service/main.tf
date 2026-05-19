terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "this" {
  name         = var.image
  keep_locally = true
}

resource "docker_container" "this" {
  name  = var.name
  image = docker_image.this.image_id

  env = var.env

  dynamic "volumes" {
    for_each = var.volumes
    content {
      volume_name    = volumes.value.volume_name
      container_path = volumes.value.container_path
    }
  }

  networks_advanced {
    name = var.network_id
  }

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  restart = "unless-stopped"
}