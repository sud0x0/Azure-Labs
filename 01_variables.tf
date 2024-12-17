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

locals {
  vm_size_sku                   = local.yaml_data_2.tf_only_variables.vm_size_sku
  linux_publisher               = local.yaml_data_2.tf_only_variables.linux_publisher
  linux_image_sku               = local.yaml_data_2.tf_only_variables.linux_image_sku
  linux_offer                   = local.yaml_data_2.tf_only_variables.linux_offer
  azure_monitor_linux_version   = local.yaml_data_2.tf_only_variables.azure_monitor_linux_version
  windows_publisher             = local.yaml_data_2.tf_only_variables.windows_publisher
  windows_offer                 = local.yaml_data_2.tf_only_variables.windows_offer
  windows_image_sku             = local.yaml_data_2.tf_only_variables.windows_image_sku
  azure_monitor_windows_version = local.yaml_data_2.tf_only_variables.azure_monitor_windows_version
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
