// modules/aca-environment.bicep - Azure Container Apps Environment

param envName string
param location string = resourceGroup().location
param logAnalyticsCustomerId string
@secure()
param logAnalyticsSharedKey string
param tags object = {}

resource acaEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: envName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsSharedKey
      }
    }
  }
  tags: tags
}

output envId string = acaEnv.id
output envName string = acaEnv.name
