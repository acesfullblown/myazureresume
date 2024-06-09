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
        }
      }
    ]
  }
}
