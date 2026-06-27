// modules/log-analytics.bicep - Log Analytics Workspace

param workspaceName string
param location string = resourceGroup().location
param tags object = {}

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
  tags: tags
}

output workspaceId string = workspace.id
output workspaceCustomerId string = workspace.properties.customerId
@secure()
output workspaceSharedKey string = workspace.listKeys().primarySharedKey
