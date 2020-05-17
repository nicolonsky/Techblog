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

/** 
resource "azurerm_role_assignment" "example" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = ""
}
**/

resource "azurerm_policy_assignment" "example" {
  for_each             = var.azResourceTags
  name                 = "require-tag-${each.key}"
  scope                = azurerm_resource_group.rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
  description          = "Enforce proper resource tagging"
  display_name         = "Require ${each.key} tag on all resources"

  location = "centralus"
  identity { type = "SystemAssigned" }

  parameters = <<PARAMETERS
        {
        "tagName": {
            "value": "${each.key}"
        }
    }

    PARAMETERS
}

# from https://msandbu.org/automating-azure-sentinel-deployment-using-terraform-and-powershell/
resource "azurerm_log_analytics_workspace" "la" {
  name                = var.azLogAnalyticsWorkspace.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.azLogAnalyticsWorkspace.retention_in_days
  tags                = var.azResourceTags
}

resource "azurerm_log_analytics_solution" "as" {
  solution_name         = "SecurityInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.la.id
  workspace_name        = azurerm_log_analytics_workspace.la.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}