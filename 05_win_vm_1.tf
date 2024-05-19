# VM 1 - Name: Server-Win-1
## public IP
resource "azurerm_public_ip" "Server-Win-1_ip" {
  name                = join("-", [local.project_name, "Server-Win-1-IP"])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags                = local.common_tags

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

# Network Security Group
resource "azurerm_network_security_group" "nsg_Server-Win-1" {
  name                = join("-", [local.project_name, "nsg_Server-Win-1"])
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
    name                       = "allow_internet_some_ports_in_1"
    priority                   = 510
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_internet_some_ports_in_2"
    priority                   = 515
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8080"
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
resource "azurerm_network_interface" "Server-Win-1_ni" {
  name                = join("-", [local.project_name, "Server-Win-1-NI"])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal_external"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Server-Win-1_ip.id
  }

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

resource "azurerm_network_interface_security_group_association" "Server-Win-1-nsg-association" {
  network_interface_id      = azurerm_network_interface.Server-Win-1_ni.id
  network_security_group_id = azurerm_network_security_group.nsg_Server-Win-1.id
}

# VM
resource "azurerm_windows_virtual_machine" "Server-Win-1" {
  name                  = join("-", [local.project_name, "Server-Win-1"])
  computer_name         = "Server-Win-1"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  tags                  = local.common_tags
  size                  = local.vm_size_sku
  admin_username        = data.azurerm_key_vault_secret.ladmin_un.value
  admin_password        = data.azurerm_key_vault_secret.ladmin_pwd.value
  network_interface_ids = [azurerm_network_interface.Server-Win-1_ni.id]
  patch_assessment_mode = "AutomaticByPlatform"

  os_disk {
    name                 = join("-", [local.project_name, "Server-Win-1-Disk"])
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = local.windows_publisher
    offer     = local.windows_offer
    sku       = local.windows_image_sku
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

resource "azurerm_virtual_machine_extension" "Server-Win-1_extention_1" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.Server-Win-1.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = local.azure_monitor_windows_version
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

resource "azurerm_monitor_data_collection_rule_association" "connect_Server-Win-1_to_rule_1" {
  name                    = "Connect-Server-Win-1-to-Rule-1"
  target_resource_id      = azurerm_windows_virtual_machine.Server-Win-1.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.win_system_log_collection_rule_1.id

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}
