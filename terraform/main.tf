terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0, <4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

##########################
# 1. Resource Group
##########################
resource "azurerm_resource_group" "rg" {
  name     = "laravel-rg"
  location = "northeurope"  # Modifiez la région si besoin
}

##########################
# 2. Service Plan (remplaçant l'ancien App Service Plan)
##########################
resource "azurerm_service_plan" "asp" {
  name                = "laravel-appservice-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "B1"

  depends_on = [azurerm_resource_group.rg]
}

##########################
# 3. Azure Database for MySQL Flexible Server
##########################
resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "laravelmysqlsrv"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  administrator_login = "mysqladmin"
  administrator_password = "P@ssw0rd1234!"
  sku_name            = "B_Standard_B1ms"
  version            = "8.0.21"
  zone               = "1"

  storage {
    size_gb = 20
  }
}

resource "azurerm_mysql_flexible_database" "mysql_db" {
  name                = "laraveldb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb3"
  collation           = "utf8mb3_general_ci"
}

##########################
# 4. Génération d'une clé d'application Laravel
##########################
resource "random_password" "app_key" {
  length  = 32
  special = false
}

##########################
# 5. Linux Web App (App Service)
##########################
resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      docker_image_name        = "${azurerm_container_registry.acr.login_server}/laravel-app:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }

    health_check_path = "/health"
    health_check_eviction_time_in_min = 2

    container_registry_use_managed_identity = false
    
    # Configuration des conteneurs
    container_registry_managed_identity_client_id = null
    always_on                                    = true
    minimum_tls_version                          = "1.2"
    vnet_route_all_enabled                       = false
    
    # Surveillance des conteneurs
    health_check_eviction_time_in_min = 2
    load_balancing_mode               = "LeastRequests"
    worker_count                      = 1
    
    application_logs {
      file_system_level = "Information"
    }

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }

    # Métriques détaillées
    detailed_error_logging_enabled = true
    failed_request_tracing_enabled = true
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing = true

    application_logs {
      file_system_level = "Information"
    }

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.acr.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITES_PORT"                       = "8080"
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = "1800"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITE_HEALTHCHECK_MAXPINGFAILURES" = "3"
    "APP_ENV"       = "production"
    "APP_DEBUG"     = "false"
    "APP_KEY"       = "base64:${base64encode(random_password.app_key.result)}"
    "APP_URL"       = "https://${var.web_app_name}.azurewebsites.net"
    "DB_CONNECTION" = "mysql"
    "DB_HOST"       = azurerm_mysql_flexible_server.mysql.fqdn
    "DB_PORT"       = "3306"
    "DB_DATABASE"   = azurerm_mysql_flexible_database.mysql_db.name
    "DB_USERNAME"   = azurerm_mysql_flexible_server.mysql.administrator_login
    "DB_PASSWORD"   = azurerm_mysql_flexible_server.mysql.administrator_password
  }

  depends_on = [
    azurerm_service_plan.asp,
    azurerm_mysql_flexible_server.mysql,
    azurerm_mysql_flexible_database.mysql_db
  ]
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "laravelcounteracr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}
