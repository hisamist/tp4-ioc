output "app_url" {
  description = "URL de l'application"
  value       = "http://localhost:${var.app_port}"
}

output "network_name" {
  description = "Nom du reseau Docker"
  value       = docker_network.app_network.name
}

output "container_names" {
  description = "Noms des conteneurs"
  value = {
    app      = module.app.container_name
    postgres = module.postgres.container_name
    redis    = module.redis.container_name
  }
}
