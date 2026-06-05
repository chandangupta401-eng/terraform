resource "azurerm_resource_group" "rg" {
name = "RG1"
location = "centralindia"
}
resource "azurerm_virtual_network" "vnet" {
    for_each = var.vnets 
name = each.key
resource_group_name = azurerm_resource_group.rg.name
location = azurerm_resource_group.rg.location
address_space = each.value.address_space


}
resource "azurerm_subnet" "subnet" {
     for_each = var.vnets 
    name = each.value.vm_name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
resource_group_name = azurerm_resource_group.rg.name
address_prefixes = each.value.subnet_prefix
}
resource "azurerm_public_ip" "pbip" {
     for_each = var.vnets 
  name                = "pubip-${each.value.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
     for_each = var.vnets 
  name                = "nic-${each.value.vm_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    
    name                          = "internal-${each.value.vm_name}"
    subnet_id                     = azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pbip[each.key].id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Inline Security Rule Example
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "associatedNSG-NIC" {
   for_each = var.vnets 
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vnets 
  name                = each.value.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password = "Window@1234"
  disable_password_authentication = false
  network_interface_ids     = [
    azurerm_network_interface.nic[each.key].id,
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  #  for_each = var.vnets
  name                      = "vnet1-to-vnet2"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet["vnet1"].name
  remote_virtual_network_id = azurerm_virtual_network.vnet["vnet2"].id

}

resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  name                      = "vnet2-to-vnet1"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet["vnet2"].name
  remote_virtual_network_id = azurerm_virtual_network.vnet["vnet1"].id

}