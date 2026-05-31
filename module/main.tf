module "rgs" {
    source = "./RG"
for_each = var.sunil
sunil  =each.value.name
sunil_l = each.value.location
}
module "vn" {
    
    for_each = var.sunil
    source = "./VNET"
    vnetname = each.value.vnet
    address = each.value.address
    vnetrg = module.rgs[each.key].rg_name
    rglocation = each.value.location

}
 module  "sto" {
    
 source = "./STO"
for_each = var.sunil
 sunil  =  each.value.name
sunil_l = each.value.location
sto = each.value.sto

 }

 module "subn" {
    source = "./sub"
    for_each = var.sunil
    sub = each.value.sub
  sunil  =each.value.name
  vnet = module.vn[each.key].vn-name
  address = each.value.subaddress
 }
module "vmmachine" {
    source = "./VM"
    depends_on = [ module.subn ]
    for_each = var.sunil
    vm = each.value.vm
    subid = module.subn[each.key].idsub
    sunil  =each.value.name
    sunil_l = each.value.location
}

# variable "vnetname" {}
# variable "address" {}
# variable "vnetrg" {}
# variable "rglocation" {}

