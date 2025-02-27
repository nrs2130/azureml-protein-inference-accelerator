@description('Location for the Private Endpoint.')
param location string

@description('Resource ID of the subnet.')
param subnetId string

@description('Resource ID of the AML workspace.')
param amlWorkspaceResourceId string

@description('Name for the private endpoint resource.')
param privateEndpointName string

// Use a new enough API version that requires properties for groupIds & privateLinkServiceId
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
}

output amlPrivateEndpointId string = amlPrivateEndpoint.id



