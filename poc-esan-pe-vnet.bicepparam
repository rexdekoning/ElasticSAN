using './azq-virtual-network/main.bicep'

param name = 'rdk-vnet-poc-esan-pe'
param location = 'westeurope'
param addressPrefixes = [
  '10.0.2.0/23'
]
param subnets = [
  {
    name: 'default'
    addressPrefix: '10.0.2.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
]
