@description('Location for the VNet & Private Endpoint resources.')
param location string

@description('Name of the Virtual Network.')
param vnetName string

@description('Name for the Private Endpoint resource.')
param privateEndpointName string

@description('Resource ID of the AML workspace (for private link).')
param amlWorkspaceResourceId string

@description('Resource ID of the subnet (e.g., <vnetResourceId>/subnets/<subnetName>).')
param subnetId string

// Sample: Create the VNet
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// Create the Private Endpoint
resource amlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'amlWorkspace'
        properties: {
          groupIds: [
            'amlworkspace'
          ]
          privateLinkServiceId: amlWorkspaceResourceId
        }
      }
    ]
  }
  // dependsOn: [ vnet ]  <-- optional, typically not required if referencing vnet outputs or subnetId
}

output vnetId string = vnet.id

