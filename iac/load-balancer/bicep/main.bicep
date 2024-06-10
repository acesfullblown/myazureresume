// vNet
resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-dev-eastus-001'
  location: 'East US'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          natGateway: {
            id: natGateway.id
          }
        }
      }
    ]
  }
}
// NAT Gateway
resource natPublicIP 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: concat('ip-', natGateway.name)
  location: 'East US'
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
resource natGateway 'Microsoft.Network/natGateways@2023-11-01' = {
  name: 'ng-dev-eastus-001'
  location: 'East US'
  sku: {
    name: 'Standard'
  }
}
