targetScope = 'subscription'

// Resource group name where the AML workspace is located
@description('The resource group of the existing AML workspace.')
param amlWorkspaceRg string

// The AML workspace name
@description('Name of the existing AML workspace.')
param amlWorkspaceName string

@description('AAD Object ID for the Admin. Leave blank to skip.')
param adminObjectId string

@description('AAD Object ID for Data Scientist. Leave blank to skip.')
param dataScientistObjectId string

@description('AAD Object ID for Readers. Leave blank to skip.')
param readerObjectId string

var ownerRoleId   = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var dataSciRoleId = 'f6c7c914-8db3-469d-8ca1-694a8f32e121'
var readerRoleId  = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

// 1) Reference the existing RG at subscription scope
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: amlWorkspaceRg
}

// 2) Reference the existing AML workspace inside that RG
resource existingAml 'Microsoft.MachineLearningServices/workspaces@2023-04-01' existing = {
  name: amlWorkspaceName
  scope: rg
}

// 3) Admin role assignment
resource adminAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (adminObjectId != '') {
  name: guid('${existingAml.id}/owners', adminObjectId)
  scope: existingAml
  properties: {
    principalId: adminObjectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', ownerRoleId)
    principalType: 'User'
  }
}

// 4) Data Scientist assignment
resource dsAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (dataScientistObjectId != '') {
  name: guid('${existingAml.id}/datascientist', dataScientistObjectId)
  scope: existingAml
  properties: {
    principalId: dataScientistObjectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', dataSciRoleId)
    principalType: 'User'
  }
}

// 5) Reader assignment
resource readerAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (readerObjectId != '') {
  name: guid('${existingAml.id}/reader', readerObjectId)
  scope: existingAml
  properties: {
    principalId: readerObjectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleId)
    principalType: 'User'
  }
}

