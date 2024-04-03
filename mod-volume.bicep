@description('Required. Name of the Elastic SAN')
param eSanName string

@description('Required. Name of the VolumeGroup')
param volumeGroupName string

@description('Required. Volume information')
param VolumeData array

resource volumes 'Microsoft.ElasticSan/elasticSans/volumegroups/volumes@2023-01-01' = [for volume in VolumeData: {
    name: '${eSanName}/${volumeGroupName}/${volume.Name}'
    properties: {
        sizeGiB: volume.sizeGiB
    }
}]


