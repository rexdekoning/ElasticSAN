using './azq-virtual-network/main.bicep'

param name = 'rdk-vnet-poc-esan'
param location = 'westeurope'
param addressPrefixes = [
  '10.0.0.0/23'
]
param subnets = [
  {
    name: 'default'
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
]
