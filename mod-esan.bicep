@description('Required. Name of the Elastic SAN')
param eSanName string

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Tags')
param tags object = {}

@description('Optional. AvailabiltyZone to deploy Elastic SAN. When provided options are 1, 2, 3 or a combination of those')
param availabilityZones array = []

@description('Required. The base size of the Elastic SAN in TiB')
param baseSizeTib int

@description('Optional. The extended capcity size of the Elastic SAN in TiB, default to 0')
param extendedCapacitySizeTiB int = 0

@allowed([
    ''
    'Enabled'
    'Disabled'
])
@description('Optional. Allow or disallow public network access to ElasticSan')
param publicNetworkAccess string = ''

@allowed([
    'Premium_LRS'
    'Premium_ZRS'
])
@description('Required. The preferred SKU')
param skuName string

@description('Optional. The preferred Tier. Premium is currently the onlyone')
param tier string = 'Premium'

@description('Required. Volume information')
param eSanData array

resource elasticSanResource 'Microsoft.ElasticSan/elasticSans@2023-01-01' = {
    name: eSanName
    location: location
    properties: {
        availabilityZones: availabilityZones
        baseSizeTiB: baseSizeTib
        extendedCapacitySizeTiB: extendedCapacitySizeTiB
        publicNetworkAccess: publicNetworkAccess
        sku: {
            name: skuName
            tier: tier
        }
    }
    tags: tags
}

// resource volumeGroup 'Microsoft.ElasticSan/elasticSans/volumegroups@2023-01-01' = [for vg in eSanData: {
//     name: vg.VolumeGroupName
//     parent: elasticSanResource
//     identity: vg.Identity
//     properties: {
//         protocolType: 'Iscsi'
//         networkAcls: {
//             virtualNetworkRules: [for subnetId in vg.subnetIds: {
//                 id: subnetId
//             }]
//         }
//     }
// }]

resource volumeGroup 'Microsoft.ElasticSan/elasticSans/volumegroups@2023-01-01' = [for vg in eSanData: if (publicNetworkAccess == 'Disabled') {
    name: vg.VolumeGroupName
    parent: elasticSanResource
    identity: vg.Identity
    properties: {
        protocolType: 'Iscsi'
        // networkAcls: {
        //     virtualNetworkRules: [for subnetId in vg.subnetIds: {
        //         id: subnetId
        //     }]
        // }
    }
}]

resource volumeGroup2 'Microsoft.ElasticSan/elasticSans/volumegroups@2023-01-01' = [for vg in eSanData: if (publicNetworkAccess != 'Disabled') {
    name: vg.VolumeGroupName
    parent: elasticSanResource
    properties: {
        networkAcls: {
            virtualNetworkRules: [for subnetId in vg.subnetIds: {
                id: subnetId
            }]
        }
    }
}]

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
    name: 'privatelink.blob.storage.azure.net'
    location: 'Global'
    tags: { }
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDNSZone
  name: 'dns-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: '/subscriptions/8cfe6616-141b-4207-8da3-4e3904d715a7/resourceGroups/rdk-esan-poc/providers/Microsoft.Network/virtualNetworks/rdk-vnet-poc-esan-pe'
    }
  }
}

resource privateEndPoint 'Microsoft.Network/privateEndpoints@2023-04-01' = [for vg in eSanData: if (publicNetworkAccess == 'Disabled') {
    name: 'pe-${vg.VolumeGroupName}'
    location: location
    dependsOn: volumeGroup
    properties: {
        privateLinkServiceConnections: [
            {
                name: 'pe-${vg.VolumeGroupName}'
                properties: {
                    groupIds: [
                        vg.VolumeGroupName
                    ]
                    privateLinkServiceId: elasticSanResource.id
                    requestMessage: ''
                }
            }
        ]
        subnet: {
            id: vg.subnetIds[0]
        }
    }

    
}]

resource zones 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = [for vg in eSanData: if (publicNetworkAccess == 'Disabled') {
    name: 'pe-${vg.VolumeGroupName}/privateDnsZoneGroups'
    properties: {
        privateDnsZoneConfigs: [
        {
            name: 'zoneconfig-${vg.VolumeGroupName}'
            properties: {
                privateDnsZoneId: privateDNSZone.id
            }
        }
        ]
    }
}]

module volumes './mod-volume.bicep' = [for vg in eSanData: {
    name: 'volume-${eSanName}-${vg.volumeGroupName}'
    dependsOn: volumeGroup
    params: {
        eSanName: eSanName
        volumeGroupName: vg.VolumeGroupName
        VolumeData: vg.VolumeData
    }
}]

output primaryResourceId string = elasticSanResource.id
