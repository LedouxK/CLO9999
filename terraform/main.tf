resource "azurerm_resource_group" "rg" {
  name     = "laravel-rg"
  location = "northeurope"
}

# Storage Account pour les uploads Laravel
resource "azurerm_storage_account" "storage" {
  name                     = "laravelcounterfiles"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_service_plan" "asp" {
  name                = "laravel-appservice-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type            = "Linux"
  sku_name           = "B1"
}

# Serveur MySQL Flexible
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "laravelmysqlsrv"
  resource_group_name    = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  administrator_login    = "mysqladmin"
  administrator_password = "P@ssw0rd2024#SecureDB"
  backup_retention_days  = 7
  delegated_subnet_id    = null
  private_dns_zone_id    = null
  sku_name              = "B_Standard_B1ms"

  storage {
    size_gb = 20
    iops    = 360
  }

  version = "8.0.21"
  zone    = "1"
}

# Base de données Laravel
resource "azurerm_mysql_flexible_database" "mysql_db" {
  name                = "laraveldb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation          = "utf8mb4_unicode_ci"
}

# Règles de pare-feu
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure" {
  name                = "allow-azure-services"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Règle pour GitHub Actions
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_github" {
  name                = "allow-github-actions"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "20.27.177.0"  # GitHub Actions IP range
  end_ip_address      = "20.27.177.255"
}

# App Service
resource "azurerm_linux_web_app" "app" {
  name                = "laravel-counter-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      php_version = "8.2"
    }
    always_on = true
    
    # Configuration SSL
    minimum_tls_version = "1.2"
    http2_enabled = true
  }

  app_settings = {
    # Configuration de base Laravel
    "WEBSITE_DOCUMENT_ROOT" = "/home/site/wwwroot/public"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
    "APP_ENV" = "production"
    "APP_DEBUG" = "false"
    "APP_URL" = "https://laravel-counter-app.azurewebsites.net"
    "APP_KEY" = "base64:gAMeJ1jgM7jtkjKkXyNfSB/Riv8Y28+6nPgUdrCg2ik="
    
    # Configuration MySQL
    "DB_CONNECTION"        = "mysql"
    "DB_HOST"             = azurerm_mysql_flexible_server.mysql.fqdn
    "DB_PORT"             = "3306"
    "DB_DATABASE"         = azurerm_mysql_flexible_database.mysql_db.name
    "DB_USERNAME"         = "${azurerm_mysql_flexible_server.mysql.administrator_login}@${azurerm_mysql_flexible_server.mysql.name}"
    "DB_PASSWORD"         = azurerm_mysql_flexible_server.mysql.administrator_password
    "MYSQL_SSL"           = "true"
    "MYSQL_ATTR_SSL_CA"   = "/etc/ssl/certs/Baltimore_CyberTrust_Root.crt.pem"

    # Configuration du stockage Azure
    "FILESYSTEM_DRIVER" = "azure"
    "AZURE_STORAGE_NAME" = azurerm_storage_account.storage.name
    "AZURE_STORAGE_KEY" = azurerm_storage_account.storage.primary_access_key
    "AZURE_STORAGE_CONTAINER" = azurerm_storage_container.uploads.name
    "AZURE_STORAGE_URL" = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net"
  }

  # Configuration SSL
  https_only = true

  depends_on = [
    azurerm_mysql_flexible_server.mysql,
    azurerm_mysql_flexible_database.mysql_db,
    azurerm_storage_account.storage
  ]
} 