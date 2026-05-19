variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "mon-app"
}

variable "postgres_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  sensitive   = true
}

variable "postgres_db" {
  description = "Nom de la base de donnees"
  type        = string
  default     = "appdb"
}

variable "app_port" {
  description = "Port expose de l'application"
  type        = number
  default     = 3000
}