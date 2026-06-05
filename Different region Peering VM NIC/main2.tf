resource "azurerm_resource_group" "rrg" {
name = "RG2"
location = "westus"
}
resource "azurerm_virtual_network" "rvnet" {
name ="rvnet1"
resource_group_name = azurerm_resource_group.rrg.name
location = azurerm_resource_group.rrg.location
address_space = ["20.10.0.0/16"]   
}
resource "azurerm_subnet" "rsubnet" {
    name = "rsub1"
  virtual_network_name = azurerm_virtual_network.rvnet.name
resource_group_name = azurerm_resource_group.rrg.name
address_prefixes = ["20.10.10.0/24"]
}
resource "azurerm_public_ip" "rpbip" {
  count = var.vmcount
  name                = "rpubip-${count.index+1}"
  resource_group_name = azurerm_resource_group.rrg.name
  location            = azurerm_resource_group.rrg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "rnic" {
  count = var.vmcount
  name                = "rnic-${count.index+1}"
  location            = azurerm_resource_group.rrg.location
  resource_group_name = azurerm_resource_group.rrg.name

  ip_configuration {
    name                          = "rinternal"
    subnet_id                     = azurerm_subnet.rsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.rpbip[count.index].id
  }
}

resource "azurerm_network_security_group" "rnsg" {
  name                = "rnsg1"
  location            = azurerm_resource_group.rrg.location
  resource_group_name = azurerm_resource_group.rrg.name

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

resource "azurerm_network_interface_security_group_association" "rassociatedNSG-NIC" {
  count = var.vmcount
  network_interface_id      = azurerm_network_interface.rnic[count.index].id
  network_security_group_id = azurerm_network_security_group.rnsg.id
}

resource "azurerm_linux_virtual_machine" "rvm" {
  count = var.vmcount
  name                = "rvm-${count.index+1}"
  resource_group_name = azurerm_resource_group.rrg.name
  location            = azurerm_resource_group.rrg.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password = "Window@1234"
  disable_password_authentication = false
  network_interface_ids     = [
    azurerm_network_interface.rnic[count.index].id,
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
resource "azurerm_virtual_network_peering" "Peer2" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.rrg.name
  virtual_network_name      = azurerm_virtual_network.rvnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}


