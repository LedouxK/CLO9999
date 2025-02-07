terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0, <4.0.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Activation du provider GitHub
provider "github" {
  token = var.github_token
  owner = var.github_organization
}

# Groupe de Ressources
resource "azurerm_resource_group" "rg" {
  name     = "laravel-rg"
  location = "northeurope"
}

# Plan d'hébergement Azure App Service
resource "azurerm_service_plan" "asp" {
  name                = "laravel-appservice-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"  # Plan de base moins cher
}

# Base de données MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "laravelmysqlsrv"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  administrator_login = "mysqladmin"
  administrator_password = var.mysql_admin_password
  sku_name            = "B_Standard_B1ms"
  version             = "8.0.21"
  zone                = "1"

  storage {
    size_gb = 20
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
}

# Base de données Laravel
resource "azurerm_mysql_flexible_database" "mysql_db" {
  name                = "laraveldb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Web App PHP 8.3
resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      php_version = "8.2"
    }
    always_on = true
    app_command_line = "php-fpm"
  }

  app_settings = {
    "APP_ENV"               = "production"
    "APP_DEBUG"             = "false"
    "APP_URL"               = "https://${var.web_app_name}.azurewebsites.net"
    "APP_KEY"               = var.app_key
    "DB_CONNECTION"         = "mysql"
    "DB_HOST"               = azurerm_mysql_flexible_server.mysql.fqdn
    "DB_PORT"               = "3306"
    "DB_DATABASE"           = azurerm_mysql_flexible_database.mysql_db.name
    "DB_USERNAME"           = azurerm_mysql_flexible_server.mysql.administrator_login
    "DB_PASSWORD"           = var.mysql_admin_password
    "FILESYSTEM_DISK"       = "azure"
    "AZURE_STORAGE_NAME"    = var.storage_account_name
    "AZURE_STORAGE_KEY"     = var.storage_account_key
    "AZURE_STORAGE_CONTAINER" = var.storage_container_name
    "AZURE_STORAGE_URL"     = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net"
    "NODE_ENV"              = "production"
    "NPM_CONFIG_PRODUCTION" = "true"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
    "PHP_OPCACHE_VALIDATE_TIMESTAMPS" = "0"
    "PHP_OPCACHE_MAX_ACCELERATED_FILES" = "10000"
    "PHP_OPCACHE_MEMORY_CONSUMPTION" = "192"
  }
}

# Storage Account pour Laravel (Stockage de fichiers)
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "files" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Secrets GitHub pour CI/CD
resource "github_actions_secret" "azure_app_name" {
  repository       = var.github_repository
  secret_name      = "AZURE_APP_NAME"
  plaintext_value  = azurerm_linux_web_app.app.name
}

resource "github_actions_secret" "azure_publish_profile" {
  repository       = var.github_repository
  secret_name      = "AZURE_PUBLISH_PROFILE"
  plaintext_value  = var.azure_publish_profile
}

resource "github_actions_secret" "app_key" {
  repository       = var.github_repository
  secret_name      = "APP_KEY"
  plaintext_value  = var.app_key
}

resource "github_actions_secret" "db_password" {
  repository       = var.github_repository
  secret_name      = "DB_PASSWORD"
  plaintext_value  = var.mysql_admin_password
}
