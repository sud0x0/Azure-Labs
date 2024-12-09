# VM 1 - Name: Server-Lin-1
## public IP
resource "azurerm_public_ip" "Server-Lin-1_ip" {
  name                = join("-", [local.project_name, "Server-Lin-1-IP"])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags                = local.common_tags

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

# Network Security Group
resource "azurerm_network_security_group" "nsg_Server-Lin-1" {
  name                = join("-", [local.project_name, "nsg_Server-Lin-1"])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.common_tags

  security_rule {
    name                       = "allow_list_all_ports_in"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = local.access_allow_list
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_list_all_ports_out"
    priority                   = 500
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "0.0.0.0"
  }

  security_rule {
    name                       = "allow_internet_some_ports_in"
    priority                   = 510
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80-8080"
    source_address_prefix      = "0.0.0.0"
    destination_address_prefix = "*"
  }

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

# Network Interfaces
resource "azurerm_network_interface" "Server-Lin-1_ni" {
  name                = join("-", [local.project_name, "Server-Lin-1-NI"])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal_external"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Server-Lin-1_ip.id
  }

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

resource "azurerm_network_interface_security_group_association" "Server-Lin-1-nsg-association" {
  network_interface_id      = azurerm_network_interface.Server-Lin-1_ni.id
  network_security_group_id = azurerm_network_security_group.nsg_Server-Lin-1.id
}

# VM
resource "azurerm_linux_virtual_machine" "Server-Lin-1" {
  name                            = join("-", [local.project_name, "Server-Lin-1"])
  computer_name                   = "Server-Lin-1"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  tags                            = local.common_tags
  size                            = local.vm_size_sku
  disable_password_authentication = false
  admin_username                  = data.azurerm_key_vault_secret.ladmin_un.value
  admin_password                  = data.azurerm_key_vault_secret.ladmin_pwd.value
  network_interface_ids           = [azurerm_network_interface.Server-Lin-1_ni.id]
  patch_assessment_mode           = "AutomaticByPlatform"
  provision_vm_agent              = true

  os_disk {
    name                 = join("-", [local.project_name, "Server-Lin-1-Disk"])
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "50"
  }

  source_image_reference {
    publisher = local.linux_publisher
    offer     = local.linux_offer
    sku       = local.linux_image_sku
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

resource "azurerm_virtual_machine_extension" "vm_Server-Lin-1_extention_1" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.Server-Lin-1.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = local.azure_monitor_linux_version
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  tags                       = local.common_tags

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

resource "azurerm_monitor_data_collection_rule_association" "connect_Server-Lin-1_to_rule_1" {
  name                    = "Connect-Server-Lin-1-to-Rule-1"
  target_resource_id      = azurerm_linux_virtual_machine.Server-Lin-1.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.lin_system_log_collection_rule_1.id

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}
