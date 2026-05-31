resource "azurerm_storage_account" "sto" {
name = var.sto
resource_group_name = var.sunil
location = var.sunil_l
account_tier = "Standard"
account_replication_type = "LRS"
}