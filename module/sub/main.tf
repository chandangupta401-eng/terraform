resource "azurerm_subnet" "subnet" {
name                 = var.sub
  resource_group_name  = var.sunil
  virtual_network_name = var.vnet
  address_prefixes     = var.address
}
output "sub-id" {
    value = azurerm_subnet.subnet.id
  
}