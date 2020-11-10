# https://www.terraform.io/docs/providers/index.html
provider "azurerm" {
    version = "~>2.0"
    features {}
    skip_provider_registration = true
}

# https://www.terraform.io/docs/providers/azurerm/r/netapp_account.html
resource "azurerm_netapp_account" "netapp_account" {
    name                        = var.naa
    location                    = var.region
    resource_group_name         = var.rg
    tags                        = var.standard_tags
    # Need to move these fields to the variables.tf file
    active_directory {
    username            = var.ad_username
    password            = var.ad_password
    smb_server_name     = var.smb_server_prefix
    dns_servers         = var.dns_servers
    domain              = var.ad_domainname
    organizational_unit = var.organizational_unit
  }
}

# https://www.terraform.io/docs/providers/azurerm/r/netapp_pool.html
resource "azurerm_netapp_pool" "netapp_pool" {
    name                        = var.pool
    account_name                = azurerm_netapp_account.netapp_account.name
    location                    = var.region
    resource_group_name         = var.rg
    service_level               = var.service_level
    size_in_tb                  = var.pool_size
    tags                        = var.standard_tags
}

# https://www.terraform.io/docs/providers/azurerm/r/subnet.html
resource "azurerm_subnet" "anf_subnet" {
  name                 = var.subnet
  resource_group_name  = var.rg
  virtual_network_name = var.vnet
  address_prefix       = var.address_range

  delegation {
    name = "netapp"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# https://www.terraform.io/docs/providers/azurerm/r/netapp_volume.html
resource "azurerm_netapp_volume" "netapp_volume" {
    lifecycle {
        prevent_destroy         = false
    }
    name                        = var.volume
    location                    = var.region
    resource_group_name         = var.rg
    account_name                = azurerm_netapp_account.netapp_account.name
    pool_name                   = azurerm_netapp_pool.netapp_pool.name
    volume_path                 = var.volume_path
    service_level               = var.service_level
    subnet_id                   = azurerm_subnet.anf_subnet.id
    protocols                   = ["CIFS"]
    storage_quota_in_gb         = var.quota
    tags                        = var.standard_tags
}

# https://www.terraform.io/docs/providers/azurerm/r/monitor_metric_alert.html
# Customer will likely already have an action group
resource "azurerm_monitor_action_group" "main" {
  name                = "AlertActionGroup"
  resource_group_name = var.rg
  short_name          = "AAG"

  azure_app_push_receiver {
      name            = "PushtoAzureApp"
      email_address   = var.alert_email_azapp
  }

  email_receiver {
      name            = "SendtoEmail"
      email_address   = var.alert_email_address
  }

  sms_receiver {
    name              = "SendtoSMS"
    country_code      = "1"
    phone_number      = var.alert_phone_sms
  }
}

resource "azurerm_monitor_metric_alert" "example" {
  name                = "ANFConsumedSpaceTF"
  resource_group_name = var.rg
  scopes              = [azurerm_netapp_volume.netapp_volume.id]
  description         = "Action will be triggered when consumed space is higher than ${var.alert_percent}% of the effective quota."

  criteria {
    metric_namespace = "Microsoft.NetApp/netAppAccounts/capacityPools/volumes"
    metric_name      = "volumelogicalsize"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = (var.quota * 1073741824) * (var.alert_percent * 0.01) # Field needs bytes!
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}