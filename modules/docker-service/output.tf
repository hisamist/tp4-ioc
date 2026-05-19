output "container_name" {
  description = "Nom du conteneur"
  value       = docker_container.this.name
}

output "container_id" {
  description = "ID du conteneur"
  value       = docker_container.this.id
}
