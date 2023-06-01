@description('The Azure regions into which the resources should be deployed.')
param locations array

@description('The IP address range for all virtual networks to use.')
param virtualNetworkAddressPrefix string

@description('The name and IP address range for each subnet in the virtual networks.')
param subnets array

@description('The name of the environment. This must be Development or Production.')
@allowed([
  'Development'
  'Production'
])
param environmentName string

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object

@description('The name of the audit storage account SKU.')
param auditStorageAccountSkuName string

var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }
}]

module databases 'modules/database.bicep' = [for location in locations: {
  name: 'database-${location}'
  params: {
    location: location
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorPassword
    environmentName:environmentName
    sqlDatabaseSku: sqlDatabaseSku
    auditStorageAccountSkuName: auditStorageAccountSkuName
  }
}]

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2021-08-01' = [for location in locations: {
  name: 'teddybear-${location}'
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        virtualNetworkAddressPrefix
      ]
    }
    subnets: subnetProperties
  }
}]

output serverInfo array = [for i in range(0, length(locations)): {
  name: databases[i].outputs.serverName
  location: databases[i].outputs.location
  fullyQualifiedDomainName: databases[i].outputs.serverFullyQualifiedDomainName
}]
