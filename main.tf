resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "laravelmysqlsrv"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  
  administrator_login    = "mysqladmin"
  administrator_password = "P@ssw0rd2024#SecureDB"
  
  sku_name = "B_Standard_B1ms"
  version  = "8.0.21"
  zone     = "1"

  backup_retention_days = 7
  
  storage {
    size_gb = 20
    iops    = 360
    auto_grow_enabled = true
  }
} 