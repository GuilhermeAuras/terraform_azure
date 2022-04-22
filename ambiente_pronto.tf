#CRIACAO DO AMBIENTE ABAIXO:
#rg: grupo criado
#vnet: network virtual
#vm-subnet: subnet virtual associada a vnet criada
#publicip: ip publico associado a vm-subnet e vnet criadas
#nic: interface network criada associada a publicip, vm-subnet e vnet
#nsg: grupo de portas tcp criadas para fins de acessos externos

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg"
  location = "brazilsouth"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vm-vnet"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.0.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  name                    = "vm-ippublic"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
  domain_name_label       = "vmtf"
}

resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipexterno-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

}

variable "regras_entrada" {
  type = map(any)
  default = {
    101 = 80
    102 = 443
    103 = 22
  }
}

resource "azurerm_network_security_rule" "regras_entrada_liberada" {
  for_each                    = var.regras_entrada
  resource_group_name         = azurerm_resource_group.rg.name
  name                        = "porta_entrada_${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  source_port_range           = "*"
  protocol                    = "Tcp"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsgassociacao" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
