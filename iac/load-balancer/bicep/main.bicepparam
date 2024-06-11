using 'main.bicep'

param location = 'East US'
param adminUsername = 'LBadmin'
param adminPassword = 'https://kv-loadbalancer-dev-001.vault.azure.net/secrets/vm1-password/8394dfeda4eb46eb91468ee34612a148'
param vnet = {
  name: 'vnet-dev-eastus-001'
  addressPrefixes: '10.0.0.0/24'
}
param nsgName = 'nsg-dev-eastus-001'
param loadBalancerName = 'lb-dev-eastus-001'
param natGatewayName = 'ng-dev-eastus-001'
param virtualMachine1 = {
  name: 'vm-dev-eastus-001'
  size: 'Standard_B2s'
  computerName: 'vm1'
  osDiskName: 'dsk-vm-dev-eastus-001'
  ipAddress: '10.0.0.5'
}
param virtualMachine2 = {
  name: 'vm-dev-eastus-002'
  size: 'Standard_B2s'
  computerName: 'vm2'
  osDiskName: 'dsk-vm-dev-eastus-002'
  ipAddress: '10.0.0.6'
}
