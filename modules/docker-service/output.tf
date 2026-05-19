output "app_url" {
  description = "URL de l'application"
  value       = "http://localhost:${var.app_port}"
}

output "postgres_port" {
  description = "Port PostgreSQL"
  value       = 5432
}

output "redis_port" {
  description = "Port Redis"
  value       = 6379
}

output "network_name" {
  description = "Nom du reseau Docker"
  value       = docker_network.app_network.name
}

output "container_names" {
  description = "Noms des conteneurs"
  value = {
    app      = docker_container.app.name
    postgres = docker_container.postgres.name
    redis    = docker_container.redis.name
  }
}