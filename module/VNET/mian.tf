resource "azurerm_virtual_network" "vnet" {
    name = var.vnetname
  location = var.rglocation
  resource_group_name = var.vnetrg
  address_space = var.address
}