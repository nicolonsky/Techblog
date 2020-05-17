variable "azResourceTags" {
  type = map(string)
  default = {
    Environment = "TEST"
    Owner       = "Nicola Suter"
    CostCenter  = "5018"
    Department  = "Workplace Engineering"
  }
}

variable "azResourceGroup" {
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = "RG-Workplace-Tools"
    location = "North Europe"
  }
}

variable "azAutomationAccountName" {
  type    = string
  default = "WorkplaceAutomation"
}

variable "azAutomationAccountModules" {
  type = map(string)
  default = {
    AzureAD                  = "https://www.powershellgallery.com/api/v2/package/AzureAD/2.0.2.4"
    "Microsoft.Graph.Intune" = "https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Intune/6.1907.1.0"
  }
}

variable "azStorageAccount" {
  type = object({
    name                     = string
    account_replication_type = string
    account_tier             = string
  })
  default = {
    name                     = "nicolonskystorage"
    account_replication_type = "LRS"
    account_tier             = "Standard"
  }
}

variable "azKeyVaultName" {
  type    = string
  default = "nicolonskyvault"
}