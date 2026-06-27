// iam/modules/role-assignment.bicep - Generic role assignment at RG scope

param roleName string
param roleDefinitionId string
param principalId string
param scopeDescription string = ''

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, roleDefinitionId, roleName, scopeDescription)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
