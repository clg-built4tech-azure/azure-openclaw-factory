// modules/container-apps.bicep - Creates Container Apps for each agent

param agentNames array
@minValue(0)
@description('Number of generic OpenClaw Container Apps to create in this environment.')
param openclawContainerAppCount int = 0
param environmentSuffix string
param acaEnvName string
param location string = resourceGroup().location
param tags object = {}

// Placeholder image — will be replaced by CI/CD deployments
var defaultImage = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
var openclawContainerAppNames = [for index in range(0, openclawContainerAppCount): 'openclaw-${index + 1}']
var containerAppNames = concat(agentNames, openclawContainerAppNames)

resource acaEnv 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: acaEnvName
}

resource containerApps 'Microsoft.App/containerApps@2024-03-01' = [for agentName in containerAppNames: {
  name: '${agentName}-${environmentSuffix}'
  location: location
  properties: {
    managedEnvironmentId: acaEnv.id
    configuration: {
      activeRevisionsMode: 'Single'
      dapr: {
        enabled: true
        appId: '${agentName}-${environmentSuffix}'
        appPort: 8080
        appProtocol: 'http'
      }
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          name: agentName
          image: defaultImage
          env: [
            {
              name: 'PORT'
              value: '8080'
            }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
  tags: tags
}]

output fqdns array = [for i in range(0, length(containerAppNames)): {
  name: containerAppNames[i]
  suffix: environmentSuffix
  fqdn: containerApps[i].properties.configuration.ingress.fqdn
}]
