@description('Location for the compute cluster')
param location string

@description('AML workspace name to attach compute under')
param workspaceName string

@description('VM Size (e.g., Standard_DS3_v2 or Standard_NC6s_v3)')
param vmSize string

@description('Minimum # of nodes')
param minNodeCount int

@description('Maximum # of nodes')
param maxNodeCount int

resource amlCompute 'Microsoft.MachineLearningServices/workspaces/computes@2023-04-01' = {
  name: '${workspaceName}/default-compute'
  location: location  // <-- Add this property
  properties: {
    computeType: 'AmlCompute'
    properties: {
      vmSize: vmSize
      scaleSettings: {
        minNodeCount: minNodeCount
        maxNodeCount: maxNodeCount
        nodeIdleTimeBeforeScaleDown: 'PT30M'
      }
    }
  }
}

output computeName string = amlCompute.name
