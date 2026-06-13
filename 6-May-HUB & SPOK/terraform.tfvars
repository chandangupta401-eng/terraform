
vnets = {
  HUBvnet = {
    address_space = ["10.0.0.0/16"]
    subnet_name   = "AzureFirewallSubnet"
    subnet_prefix = ["10.0.1.0/24"]
    vm_name       = "vm1"
  }
  
    SPOK1vnet = {
    address_space = ["11.1.0.0/16"]
    subnet_name   = "SPOK1SUB"
    subnet_prefix = ["11.1.1.0/24"]
    vm_name       = "vm2"
  } 
  SPOK2vnet = {
    address_space = ["12.1.0.0/16"]
    subnet_name   = "SPOK2SUB"
    subnet_prefix = ["12.1.1.0/24"]
    vm_name       = "vm2"
  }
}
