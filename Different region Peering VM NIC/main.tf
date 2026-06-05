
resource "azurerm_resource_group" "rg" {
name = "RRG1"
location = "eastus"
}
resource "azurerm_virtual_network" "vnet" {
name ="vnet1"
resource_group_name = azurerm_resource_group.rg.name
location = azurerm_resource_group.rg.location
address_space = ["10.10.0.0/16"]   
}
resource "azurerm_subnet" "subnet" {
    name = "sub1"
  virtual_network_name = azurerm_virtual_network.vnet.name
resource_group_name = azurerm_resource_group.rg.name
address_prefixes = ["10.10.10.0/24"]
}
resource "azurerm_public_ip" "pbip" {
  count = var.vmcount
  name                = "pubip-${count.index+1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  count = var.vmcount
  name                = "nic-${count.index+1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pbip[count.index].id
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
  count = var.vmcount
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = var.vmcount
  name                = "vm-${count.index+1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password = "Window@1234"
  disable_password_authentication = false
  network_interface_ids     = [
    azurerm_network_interface.nic[count.index].id,
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
resource "azurerm_virtual_network_peering" "Peer1" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = azurerm_virtual_network.rvnet.id
}



