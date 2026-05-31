variable "vm" {}
variable "sunil" {}
variable "sunil_l" {}
variable "subid" {}

resource "azurerm_public_ip" "pbip" {
  name                = "pubip1"
  resource_group_name = var.sunil
  location            = var.sunil_l
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic1"
  location            = var.sunil_l
  resource_group_name = var.sunil

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subid
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pbip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg1"
  location            = var.sunil_l
  resource_group_name = var.sunil

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
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm1"
  resource_group_name = var.sunil
  location            = var.sunil_l
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password = "Window@1234"
  disable_password_authentication = false
  network_interface_ids     = [
    azurerm_network_interface.nic.id,
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