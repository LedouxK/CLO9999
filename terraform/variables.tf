variable "github_token" {
  description = "Token GitHub pour l'accès à l'API"
  type        = string
  sensitive   = true
}

variable "web_app_name" {
  description = "Nom de l'application web"
  type        = string
  default     = "laravel-app"
}

variable "mysql_admin_password" {
  description = "Mot de passe administrateur MySQL"
  type        = string
  sensitive   = true
}

variable "app_key" {
  description = "Clé de chiffrement Laravel"
  type        = string
  sensitive   = true
}

variable "storage_account_name" {
  description = "Nom du compte de stockage Azure"
  type        = string
  default     = "laravelfiles"
}

variable "storage_account_key" {
  description = "Clé du compte de stockage Azure"
  type        = string
  sensitive   = true
}

variable "storage_container_name" {
  description = "Nom du conteneur de stockage"
  type        = string
  default     = "laravel-files"
}

variable "github_repo_url" {
  description = "URL du dépôt GitHub"
  type        = string
  default     = "https://github.com/LedouxK/CLO9999.git"
}

variable "github_organization" {
  description = "Organisation GitHub"
  type        = string
  default     = "LedouxK"
}

variable "github_repository" {
  description = "Nom du dépôt GitHub"
  type        = string
  default     = "CLO9999"
}

variable "azure_publish_profile" {
  description = "Profil de publication Azure"
  type        = string
  sensitive   = true
}
