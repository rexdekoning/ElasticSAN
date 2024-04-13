using './mod-esan.bicep'

param eSanName = 'poc-esan-bicep-02'
param tags  = {}
param availabilityZones  = [
  '1'
]
param baseSizeTib = 1
param extendedCapacitySizeTiB = 0
param publicNetworkAccess = 'Enabled'
param skuName  = 'Premium_LRS'
param tier  = 'Premium'
param eSanData = [
  {
    VolumeGroupName: 'poc-esan-vg-10'
    identity: {
      type: 'None'
    }
    subnetIds: [
      '/subscriptions/8cfe6616-141b-4207-8da3-4e3904d715a7/resourceGroups/rdk-esan-poc/providers/Microsoft.Network/virtualNetworks/rdk-vnet-poc-esan/subnets/default'
    ]
    VolumeData: [
      {
        Name: 'poc-esan-vg-10-vol-01'
        sizeGiB:  1
      }
    ]
  }
  {
    VolumeGroupName: 'poc-esan-vg-11'
    identity: {
      type: 'None'
    }
    subnetIds: [
      '/subscriptions/8cfe6616-141b-4207-8da3-4e3904d715a7/resourceGroups/rdk-esan-poc/providers/Microsoft.Network/virtualNetworks/rdk-vnet-poc-esan/subnets/default'
    ]
    VolumeData: [
      {
        Name: 'poc-esan-vg-11-vol-01'
        sizeGiB:  1
      }
      {
        Name: 'poc-esan-vg-11-vol-02'
        sizeGiB:  1
      }
    ]
  }
]

