/*
** Azure bicep template for Senzing axure-template-aks-poc-simple
*/

// targetScope = 'subscription'

/*
** ----------------------------------------------------------------------------
** Parameters
** ----------------------------------------------------------------------------
*/

// -- Senzing -----------------------------------------------------------------

@allowed([
  'I AGREE'
])
@description('Required: A default deployment of this template is for public demonstration only.  Before using authentic PII, ensure the security of your deployment.  The security of this deployment is your responsibility.  To acknowledge your understanding and acceptance of the foregoing, type “I AGREE”')
param securityResponsibility string

@allowed([
  'I_ACCEPT_THE_SENZING_EULA'
])
@description('Required: If you accept the Senzing End User License Agreement at https://senzing.com/end-user-license-agreement, enter "I_ACCEPT_THE_SENZING_EULA"')
param acceptEula string

@description('Required if inserting more than 100K records.  Senzing license as base64 encoded string')
param senzingLicenseAsBase64 string = ''

// -- Environment -------------------------------------------------------------

@description('Resource group to deploy into.')
param location string = resourceGroup().location

@description('The name of the environment. This must be Development or Production.')
@allowed([
  'Development'
  'Production'
])
param environmentName string = 'Development'

// -- Database ----------------------------------------------------------------

@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@description('The administrator login password for the SQL server.')
@secure()
param sqlServerAdministratorLoginPassword string

/*
** ----------------------------------------------------------------------------
** Variables
** ----------------------------------------------------------------------------
*/

var auditStorageAccountName = '${take('senzing-audit-${location}-${uniqueString(resourceGroup().id)}', 24)}'
var auditStorageAccountSkuName = 'Standard_LRS'
var sqlDatabaseName = 'G2'
var sqlServerName = 'senzing-${location}-${uniqueString(resourceGroup().id)}'

/*
** ----------------------------------------------------------------------------
** Modules
** ----------------------------------------------------------------------------
*/

module database 'modules/database.bicep' = {
  name: 'database'
  params: {
    auditStorageAccountName: auditStorageAccountName
    auditStorageAccountSkuName: auditStorageAccountSkuName
    environmentName: environmentName
    location: location
    sqlDatabaseName: sqlDatabaseName
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
    sqlServerName: sqlServerName
  }
}

/*
** ----------------------------------------------------------------------------
** Outputs
** ----------------------------------------------------------------------------
*/

output location string = location
output resourceGroupId string = resourceGroup().id
output senzingTemplateName string = 'aks-poc-simple'
output senzingTemplateVersion string = '0.1.0'
