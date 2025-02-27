targetScope = 'resourceGroup'

//--------------------------------
// 1) Parameters
//--------------------------------
@description('Azure region for the resources.')
param location string = 'eastus2'

@description('Name of the AML workspace to create.')
param workspaceName string = 'my-ml-workspace'

@description('Deploy a new VNet for private networking?')
param useVnet bool = false

@description('VM size for the default AML compute cluster.')
param vmSize string = 'Standard_DS3_v2'
param minNodeCount int = 0
param maxNodeCount int = 2

@description('Monthly budget limit in USD (0=skip).')
param monthlyBudgetLimit int = 0

// RBAC IDs (for the optional role assignments)
@description('AAD Object ID for Admin (leave blank to skip).')
param adminObjectId string = ''
@description('AAD Object ID for Data Scientists (leave blank to skip).')
param dataScientistObjectId string = ''
@description('AAD Object ID for Readers (leave blank to skip).')
param readerObjectId string = ''

@description('Resource group name for the AML workspace (defaults to current RG if the same).')
param amlWorkspaceRg string = resourceGroup().name  // If you want to keep it in the same RG

//--------------------------------
// 2) Modules
//--------------------------------

// 2.1. Network if useVnet = true
module network 'modules/network.bicep' = if (useVnet) {
  name: 'networkSetup'
  params: {
    location: location
    amlWorkspaceResourceId: workspaceName
    privateEndpointName: 'amlPrivateEndpoint'
    vnetName: 'amlVnet'
    subnetId: ''
  }
}

// 2.2. AML Workspace
module workspace 'modules/workspace.bicep' = {
  name: 'amlWorkspace'
  params: {
    location: location
    workspaceName: workspaceName
    useVnet: useVnet
  }
}

// 2.3. Monitoring
module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoringSetup'
  params: {
    location: location
    workspaceName: workspaceName
    monthlyBudgetLimit: monthlyBudgetLimit
    amlWorkspaceId: workspace.outputs.amlWorkspaceResourceId
  }
}

// 2.4. Compute
module compute 'modules/compute.bicep' = {
  name: 'computeDeployment'
  dependsOn: [
    workspace
  ]
  params: {
    location: location
    workspaceName: workspaceName
    vmSize: vmSize
    minNodeCount: minNodeCount
    maxNodeCount: maxNodeCount
  }
}

// 2.5. RBAC (subscription-scoped sub-module, name-based approach)
module rbac 'modules/rbac.bicep' = {
  name: 'rbacSetup'
  // *Important* => scope: subscription(), because rbac.bicep is subscription-scope
  scope: subscription()
  // location is optional for a subscription-scope child deployment:
  // location: location
  dependsOn: [
    workspace
  ]
  params: {
    amlWorkspaceRg: amlWorkspaceRg
    amlWorkspaceName: workspaceName
    adminObjectId: adminObjectId
    dataScientistObjectId: dataScientistObjectId
    readerObjectId: readerObjectId
  }
}

//--------------------------------
// 3) Outputs
//--------------------------------
output amlWorkspaceResourceId string = workspace.outputs.amlWorkspaceResourceId
output amlWorkspaceName string = workspace.outputs.amlWorkspaceName


