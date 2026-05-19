variable "name" {
  description = "Nom du conteneur"
  type        = string
}

variable "image" {
  description = "Image Docker a utiliser"
  type        = string
}

variable "internal_port" {
  description = "Port interne du conteneur"
  type        = number
}

variable "external_port" {
  description = "Port expose sur l'hote"
  type        = number
}

variable "network_id" {
  description = "ID du reseau Docker"
  type        = string
}

variable "env" {
  description = "Variables d'environnement"
  type        = list(string)
  default     = []
}

variable "volumes" {
  description = "Volumes a monter"
  type = list(object({
    volume_name    = string
    container_path = string
  }))
  default = []
}