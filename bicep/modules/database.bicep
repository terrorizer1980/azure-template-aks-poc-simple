/*
** ----------------------------------------------------------------------------
** Parameters
** ----------------------------------------------------------------------------
*/

@description('Account name for storage.')
param auditStorageAccountName string

@description('The name of the audit storage account SKU.')
param auditStorageAccountSkuName string = 'Standard_LRS'

@allowed([
  'Development'
  'Production'
])
@description('The name of the environment. This must be Development or Production.')
param environmentName string

@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the database.')
param sqlDatabaseName string

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object = {
  name: 'Standard'
  tier: 'Standard'
}

@description('The administrator login username for the SQL server.')
@secure()
param sqlServerAdministratorLogin string

@description('The administrator login password for the SQL server.')
@secure()
param sqlServerAdministratorLoginPassword string

@description('Server name.')
param sqlServerName string

/*
** ----------------------------------------------------------------------------
** Variables
** ----------------------------------------------------------------------------
*/

var auditingEnabled = environmentName == 'Production'

/*
** ----------------------------------------------------------------------------
** Resources
** ----------------------------------------------------------------------------
*/

// https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/2020-11-01-preview/servers?tabs=bicep
resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
  location: location
  name: sqlServerName
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/2020-11-01-preview/servers/databases?tabs=bicep
resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  location: location
  name: sqlDatabaseName
  parent: sqlServer
  sku: sqlDatabaseSku
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/2021-02-01/storageaccounts?tabs=bicep
resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = if (auditingEnabled) {
  kind: 'StorageV2'
  location: location
  name: auditStorageAccountName
  sku: {
    name: auditStorageAccountSkuName
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/2020-11-01-preview/servers/auditingsettings?tabs=bicep
resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2020-11-01-preview' = if (auditingEnabled) {
  name: 'default'
  parent: sqlServer
  properties: {
    state: 'Enabled'
    storageAccountAccessKey: environmentName == 'Production' ? listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value : ''
    storageEndpoint: environmentName == 'Production' ? auditStorageAccount.properties.primaryEndpoints.blob : ''
  }
}

/*
** ----------------------------------------------------------------------------
** Outputs
** ----------------------------------------------------------------------------
*/

output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
output serverName string = sqlServer.name
