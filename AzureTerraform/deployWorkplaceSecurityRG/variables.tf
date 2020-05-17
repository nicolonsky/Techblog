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
    name     = "RG-Workplace-Security"
    location = "North Europe"
  }
}

variable "azLogAnalyticsWorkspace" {
  type = object({
    name     = string
    retention_in_days = number
  })
  default = {
    name     = "la-workplace-security"
    retention_in_days = 365
  }
}