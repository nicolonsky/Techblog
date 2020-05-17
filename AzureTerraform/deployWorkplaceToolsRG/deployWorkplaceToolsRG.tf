provider "azurerm" {
  version = "~>2.0"
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.azResourceGroup.name
  location = var.azResourceGroup.location
  tags     = var.azResourceTags
}

resource "azurerm_policy_assignment" "example" {
  for_each             = var.azResourceTags
  name                 = "require-tag-${each.key}"
  scope                = azurerm_resource_group.rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  description          = "Enforce proper resource tagging"
  display_name         = "Require ${each.key} tag on all resources"

  parameters = <<PARAMETERS
        {
        "tagName": {
            "value": "${each.key}"
        }
    }

    PARAMETERS
}

resource "azurerm_automation_account" "aa" {
  name                = var.azAutomationAccountName
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Basic"
  tags                = var.azResourceTags
}

resource "azurerm_automation_module" "modules" {
  for_each                = var.azAutomationAccountModules
  name                    = each.key
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  module_link {
    uri = each.value
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = var.azStorageAccount.name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.azStorageAccount.account_tier
  account_replication_type = var.azStorageAccount.account_replication_type
  tags                     = var.azResourceTags

  network_rules {
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

resource "azurerm_key_vault" "kv" {
  name                     = var.azKeyVaultName
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled      = true
  purge_protection_enabled = false
  sku_name                 = "premium"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]
    secret_permissions = [
      "get",
    ]
    storage_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
  tags = var.azResourceTags
}