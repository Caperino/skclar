variable "resource_group_name" {
  type = string
}
  
variable "location" {
  default = "westus3"
  type = string
}

variable "appServiceAppName" {
  type = string
}

variable "appServicePlanName" {
  type = string
}

variable environmentType{
    type = string
}

locals {
    appServicePlanSkuName = (var.environmentType == "prod") ? "P2v3" : "F1"
    storageAccountSkuName = (var.environmentType == "prod") ? "GRS" : "LRS"
    alwaysOnSetting = (var.environmentType == "prod") ? true : false
}

resource "azurerm_service_plan" "appServicePlan" {
  name = var.appServicePlanName
  location = var.location
  resource_group_name = var.resource_group_name
  sku_name = local.appServicePlanSkuName
  os_type = "Linux"
}

resource "azurerm_linux_web_app" "appServiceApp" {
 name = var.appServiceAppName
  location = var.location
  resource_group_name = var.resource_group_name
  service_plan_id = azurerm_service_plan.appServicePlan.id
  https_only = true
  site_config {
    always_on = local.alwaysOnSetting // required according to documentation
  }
}

output "appServiceHostName" {
  value = azurerm_linux_web_app.appServiceApp.default_hostname
}
