// modules/acr.bicep - Azure Container Registry

param acrName string
param acrSku string = 'Basic'
param location string = resourceGroup().location
param tags object = {}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
  tags: tags
}

output loginServer string = acr.properties.loginServer
output acrId string = acr.id