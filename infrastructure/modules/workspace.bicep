// 1) Parameters
@description('Azure location for the workspace and related resources.')
param location string

@description('Name of the AML workspace to create.')
param workspaceName string

@description('Whether we plan to disable public network access (true => private) or not.')
param useVnet bool

// 2) Variables
var storageName  = toLower(uniqueString(resourceGroup().id, workspaceName)) // ensures uniqueness
var keyVaultName = '${workspaceName}-kv'
var insightsName = '${workspaceName}-ai'

// 3) Resources

// 3.1) Storage Account
resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

// 3.2) Key Vault
resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: []
  }
}

// 3.3) Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: insightsName
  location: location
  properties: {
    Application_Type: 'web'
  }
}

// 3.4) AML Workspace
resource amlWorkspace 'Microsoft.MachineLearningServices/workspaces@2023-04-01' = {
  name: workspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'ML workspace for protein inference'
    friendlyName: workspaceName
    keyVault: kv.id
    storageAccount: storage.id
    applicationInsights: appInsights.id
    containerRegistry: null
    // disable public net if useVnet = true
    publicNetworkAccess: useVnet ? 'Disabled' : 'Enabled'
  }
}

// 4) Outputs
output amlWorkspaceResourceId string = amlWorkspace.id
output amlWorkspaceName string = amlWorkspace.name

