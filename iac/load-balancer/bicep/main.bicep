@secure()
param adminUsername string
@secure()
param adminPassword string

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
        sourcePortRange: '3389'
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

// Load Balancer
  // Public IP
  resource loadBalancerIP 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
    name: 'ip-lb-dev-eastus-001'
    location: 'East US'
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
    }
  }
  // Balancer
  resource loadBalancer 'Microsoft.Network/loadBalancers@2023-11-01' = {
    name: 'lb-dev-eastus-001'
    location: 'East US'
    sku: {
      name: 'Standard'
    }
    properties: {
      frontendIPConfigurations: [
        {
          name: 'LoadBalancerFrontEnd'
          properties : {
            publicIPAddress: {
              id: loadBalancerIP.id
            }
          }
        }
      ]
      backendAddressPools: [
        {
          name: 'BackendPool'
          properties: {
            loadBalancerBackendAddresses: [
              {
              name: 'backendPool1'
              properties: {
                /* CANNOT GET THIS TO WORK!!
                networkInterfaceIPConfiguration: {
                }
                */
              }
              }
              {
              name: 'backendPool2'
              properties: {
                /* CANNOT GET THIS TO WORK!!
                networkInterfaceIPConfiguration: {
                }
                */
              }
              }
            ]
          }
        }
      ]
      /* CANNOT GET THIS TO WORK!!
      backendIPConfigurations: [
        {
          id: ''
        }
        {
          id: ''
        }
      ]
      */
      probes: [
        {
          name: 'HealthProbe'
          properties: {
            protocol: 'Tcp'
            port: 80
            intervalInSeconds: 5
            numberOfProbes: 1
            probeThreshold: 1
          }
        }
      ]
      loadBalancingRules: [
        {
          name: 'LoadBalancingRule'
          properties: {
            frontendIPConfiguration: {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'lb-dev-eastus-001', 'LoadBalancerFrontEnd')
            }
            backendAddressPool: {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'lb-dev-eastus-001', 'BackendPool')
            }
            frontendPort: 80
            backendPort: 80
            enableFloatingIP: false
            idleTimeoutInMinutes: 4
            protocol: 'Tcp'
            enableTcpReset: false
            loadDistribution: 'Default'
            disableOutboundSnat: true
            probe: {
              id: resourceId('Microsoft.Network/loadBalancers/probes', 'lb-dev-eastus-001', 'HealthProbe')
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

  // Virtual Machines
    // VM 1
      // NIC
      resource vm1Nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
        name: 'nic-vm-dev-eastus-001'
        location: 'East US'
        properties: {
          ipConfigurations: [
            {
              name: 'ipconfig1'
              properties: {
                subnet: {
                  id: vNet.properties.subnets[0].id
                }
                privateIPAllocationMethod: 'Static'
                privateIPAddress: '10.0.0.5'
              }
            }
          ]
        }
      }
      // VM
      resource vm1 'Microsoft.Compute/virtualMachines@2024-03-01' ={
        name: 'vm-dev-eastus-001'
        location: 'East US'
        properties: {
          hardwareProfile: {
            vmSize: 'Standard_B2s'
          }
          osProfile: {
            computerName: 'vm1'
            adminUsername: adminUsername
            adminPassword: adminPassword
          }
          storageProfile: {
            imageReference: {
              publisher: 'MicrosoftWindowsServer'
              offer: 'WindowsServer'
              sku: '2019-Datacenter'
              version: 'latest'
            }
            osDisk: {
              name: 'dsk-vm-dev-eastus-001'
              createOption: 'FromImage'
              diskSizeGB: 127
              managedDisk: {
                storageAccountType: 'Standard_LRS'
              }
            }
          }
          networkProfile: {
            networkInterfaces: [
              {
                id: vm1Nic.id
              }
            ]
          }
        }
      }

      