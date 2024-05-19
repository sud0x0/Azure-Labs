## Initial Information ##

locals {
  yaml_data_1 = yamldecode(file("vars_az.yml"))
}

locals {
  yaml_data_2 = yamldecode(file("vars_tf.yml"))
}

locals {
  owner                = local.yaml_data_1.variables.owner
  team                 = local.yaml_data_1.variables.team
  location             = local.yaml_data_1.variables.location
  project_name         = local.yaml_data_1.variables.project_name
  resource_group_name  = local.yaml_data_1.variables.rg_name
  key_vault_name       = local.yaml_data_1.variables.kv_name
  kv_key_name_1        = local.yaml_data_1.variables.kv_key_name_1
  kv_key_name_2        = local.yaml_data_1.variables.kv_key_name_2
  storage_account_name = local.yaml_data_1.variables.storage_account_name
  container_name       = local.yaml_data_1.variables.container_name
  tfstate_file_name    = local.yaml_data_1.variables.tfstate_file_name
  access_allow_list    = local.yaml_data_2.tf_only_variables.access_allow_list
  random_value         = local.yaml_data_2.tf_only_variables.random_value
}

## Virtual Machines ##

# Authenticate first: az login --scope https://management.core.windows.net//.default
# Use this command to identify the latest linux azure monitor version: az vm extension image list --location australiaeast --name AzureMonitorLinuxAgent --output table 
# Use this command to identify the latest linux image version and its offer: az vm image list --publisher Canonical --output table 
# Use this command to identify the latest windows azure monitor version: az vm extension image list --location australiaeast -o table --name AzureMonitorWindowsAgent
# Use this command to identify the latest linux image version and its offer: az vm image list --publisher windows --output table 

locals {
  vm_size_sku                   = "Standard_B2s"
  linux_publisher               = "canonical"
  linux_image_sku               = "22_04-lts-gen2"
  linux_offer                   = "0001-com-ubuntu-server-jammy"
  azure_monitor_linux_version   = "1.9"
  windows_publisher             = "MicrosoftWindowsServer"
  windows_offer                 = "WindowsServer"
  windows_image_sku             = "2022-Datacenter"
  azure_monitor_windows_version = "1.9"
}


## Tags and Build Time Limit ##

locals {
  common_tags = {
    Owner   = local.owner
    Team    = local.team
    Project = local.project_name
  }
  timeouts_create = "1h30m"
  timeouts_read   = "1h30m"
  timeouts_update = "1h30m"
  timeouts_delete = "1h30m"
}