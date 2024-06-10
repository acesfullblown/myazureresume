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
  // Public IP
  resource natPublicIP 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
    name: 'ng-dev-eastus-001'
    location: 'East US'
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
    }
  }
  // Gateway
  resource natGateway 'Microsoft.Network/natGateways@2023-11-01' = {
    name: 'ng-dev-eastus-001'
    location: 'East US'
    sku: {
      name: 'Standard'
    }
    properties: {
      idleTimeoutInMinutes: 4
      publicIpAddresses: [
        {
        id: natPublicIP.id
        }
      ]
    }
  }
// NSG
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-dev-eastus-001'
  location: 'East US'
  properties: {
    securityRules: [
      {
      name: 'RDP'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '3389'
        sourceAddressPrefix: '64.188.203.91'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 300
        direction: 'Inbound'
        }
      }
    ]
  }
}
