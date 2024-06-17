param location string
@secure()
param adminUsername string
@secure()
param adminPassword string
param vnet object
param nsgName string
param loadBalancerName string
param natGatewayName string
param virtualMachine1 object
param virtualMachine2 object

// vNet
resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnet.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet.addressPrefixes
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: vnet.AddressPrefixes
          networkSecurityGroup: {
            id: nsg.id
          }
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
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
          }
      }
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

// Load Balancer
  // Public IP
  resource loadBalancerIP 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
    name: 'ip-${loadBalancerName}'
    location: location
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
    }
  }
  // Balancer
  resource loadBalancer 'Microsoft.Network/loadBalancers@2023-11-01' = {
    name: loadBalancerName
    location: location
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
            virtualNetwork: {
              id: vnet.id
            }
            loadBalancerBackendAddresses: [
              {
              name: 'backendPool1'
              properties: {
                adminState: 'None'
                ipAddress: virtualMachine1.ipAddress
                subnet: {
                  id: vNet.properties.subnets[0].id
                }
                /*
                virtualNetwork: {
                  id: vNet.id
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
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'LoadBalancerFrontEnd')
            }
            backendAddressPool: {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, 'BackendPool')
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
              id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, 'HealthProbe')
            }
          }
        }
      ]
    }
  }

// NAT Gateway
  // Public IP
  resource natPublicIP 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
    name: 'ip-${natGatewayName}'
    location: location
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
    }
  }
  // Gateway
  resource natGateway 'Microsoft.Network/natGateways@2023-11-01' = {
    name: natGatewayName
    location: location
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
      name: 'nic-${virtualMachine1.name}'
      location: location
      properties: {
        ipConfigurations: [
          {
            name: 'ipconfig1'
            properties: {
              subnet: {
                id: vNet.properties.subnets[0].id
              }
              privateIPAllocationMethod: 'Static'
              privateIPAddress: virtualMachine1.ipAddress
            }
          }
        ]
      }
    }
    // VM
    resource vm1 'Microsoft.Compute/virtualMachines@2024-03-01' ={
      name: virtualMachine1.name
      location: location
      properties: {
        hardwareProfile: {
          vmSize: 'Standard_B2s'
        }
        osProfile: {
          computerName: virtualMachine1.computerName
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
            name: 'dsk-${virtualMachine1.name}'
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
    // Auto-Shutdown
    resource vm1AutoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
      name: 'shutdown-computevm-${virtualMachine1.name}'
      location: location
      properties: {
        status: 'Enabled'
        taskType: 'ComputeVmShutdownTask'
        dailyRecurrence: {
          time: '00:00'
        }
        timeZoneId: 'Eastern Standard Time'
        targetResourceId: vm1.id
      }
    }
  // VM 2
    // NIC
    resource vm2Nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
      name: 'nic-${virtualMachine2.name}'
      location: location
      properties: {
        ipConfigurations: [
          {
            name: 'ipconfig2'
            properties: {
              subnet: {
                id: vNet.properties.subnets[0].id
              }
              privateIPAllocationMethod: 'Static'
              privateIPAddress: virtualMachine2.ipAddress
            }
          }
        ]
      }
    }
    // VM
    resource vm2 'Microsoft.Compute/virtualMachines@2024-03-01' ={
      name: virtualMachine2.name
      location: location
      properties: {
        hardwareProfile: {
          vmSize: 'Standard_B2s'
        }
        osProfile: {
          computerName: virtualMachine2.computerName
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
            name: 'dsk-${virtualMachine2.name}'
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
              id: vm2Nic.id
            }
          ]
        }
      }
    }
    // Auto-Shutdown
    resource vm2AutoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
      name: 'shutdown-computevm-${virtualMachine2.name}'
      location: location
      properties: {
        status: 'Enabled'
        taskType: 'ComputeVmShutdownTask'
        dailyRecurrence: {
          time: '00:00'
        }
        timeZoneId: 'Eastern Standard Time'
        targetResourceId: vm2.id
      }
    }
