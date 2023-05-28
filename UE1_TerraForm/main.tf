terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features { }
}

variable "resourceGroupId" {
  default = "learn-9fd43695-2111-4ab9-9b75-14c6ee0d357b" // works fine IF az account set --subscription=... is done
  type = string
}

data "azurerm_resource_group" "rg" {
  name = var.resourceGroupId
}

variable "location" {
  default = "westus3"
  type = string
}

variable "storageAccountName" {
  default = "standard"
  type = string
}

variable "appServiceAppName" {
  default = "standard"
  type = string
}

variable "appServicePlanName" {
  default = "toy-product-launch-plan"
  type = string
}

variable "environmentType" {
    validation {
      condition = var.environmentType == "prod" || var.environmentType == "nonprod"
      error_message = "environmentType must be either 'prod' or 'nonprod'"
    }
    type = string
}

locals{
    storageAccountSkuName = (var.environmentType == "prod") ? "GRS" : "LRS"
    storageAccountName = (var.storageAccountName == "standard") ? "toylaunch${substr(sha1(data.azurerm_resource_group.rg.id), 0, 14)}" : var.storageAccountName
    appServiceAppName = (var.appServiceAppName == "standard") ? "toylaunch${substr(sha1(data.azurerm_resource_group.rg.id), 0, 14)}" : var.appServiceAppName
}

resource "azurerm_storage_account" "storageAccount" {
  name                     = local.storageAccountName
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = local.storageAccountSkuName
}

module "appService" {
  source = "./modules"
  resource_group_name = data.azurerm_resource_group.rg.name
  location = var.location
  appServiceAppName = local.appServiceAppName
  appServicePlanName = var.appServicePlanName
  environmentType = var.environmentType
}

output "appServiceHostName" {
  value = module.appService.appServiceHostName
}

// WORKFLOW
// 1 - az login
// 2 - az account set --subscription=...
// 3 - terraform init
// 4 - terraform plan
// 5 - terraform apply -var="resourceGroupId=[[NAME OF RESOURCE GROUP]]"
// add-on to above --> for me, the actual name worked to identify the resource group, not the ID