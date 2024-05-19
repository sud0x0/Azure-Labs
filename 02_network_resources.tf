# 1 virtual network and subnet
resource "azurerm_virtual_network" "vnet" {
  name                = join("-", [local.project_name, "Virtual-Network"])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = join("-", [local.project_name, "Subnet-1"])
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

# Create a log analytics workspace
resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = join("-", [local.project_name, "Log-Analytics-Workspace"])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.common_tags
  sku                 = "PerGB2018"
  retention_in_days   = 30

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

# Connect the workspace to sentinel
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "connection_to_sentinel" {
  workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    delete = local.timeouts_delete
  }
}