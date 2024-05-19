resource "azurerm_monitor_data_collection_rule" "lin_system_log_collection_rule_1" {
  name                = join("-", [local.project_name, "Linux-System-Log-Collection-Rule-1"])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
      name                  = join("-", [local.project_name, "log-analytics-rule-1-lin", local.random_value])
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = [join("-", [local.project_name, "log-analytics-rule-1-lin", local.random_value])]
  }

  data_sources {
    syslog {
      facility_names = ["daemon", "syslog"]
      log_levels     = ["Warning", "Error", "Critical", "Alert", "Emergency"]
      name           = "eventLogsDataSource"
    }
  }

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}

resource "azurerm_monitor_data_collection_rule" "win_system_log_collection_rule_1" {
  name                = join("-", [local.project_name, "Windows-System-Log-Collection-Rule-1"])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  kind                = "Windows"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
      name                  = join("-", [local.project_name, "log-analytics-rule-1-win", local.random_value])
    }
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = [join("-", [local.project_name, "log-analytics-rule-1-win", local.random_value])]
  }

  data_sources {
    windows_event_log {
      streams = ["Microsoft-Event"]
      x_path_queries = ["Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]",
        "Security!*[System[(band(Keywords,13510798882111488))]]",
      "System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]"]
      name = "eventLogsDataSource"
    }
  }

  timeouts {
    create = local.timeouts_create
    read   = local.timeouts_read
    update = local.timeouts_update
    delete = local.timeouts_delete
  }
}