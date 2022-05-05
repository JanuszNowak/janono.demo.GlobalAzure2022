@description('Specifies region of RG.')
param location string = resourceGroup().location

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

param instLocation array = [
  'westeurope'
  'eastus2'
]
param instName array = [
  'euw'
  'use2'
]

@description('Type of environment where this deployment should occur.')
@allowed([
  'dev'
  'prod'
  'jnno'
  'test'
])
 param environmentType string = 'dev'

@description('Name of Application.')
param applicationName string = 'gab2022'
param storageConfig object = {
  kind: 'StorageV2'
  accessTier: 'Hot'
  httpsTrafficOnlyEnabled: true
}
param nameConv object = {
  storageAccountName: 'stacc'
  hostingPlanName: 'plan'
  siteName: 'site'
  trafficManagerName: 'tmanager'
  appins: 'appins'
}

var namestorage = '${applicationName}${environmentType}'
var name = '${applicationName}-${environmentType}'

resource namestorage_instName_nameConv_storageAccountName 'Microsoft.Storage/storageAccounts@2021-04-01' = [for (item, i) in instLocation: {
  sku: {
    name: storageAccountType
  }
  kind: storageConfig.kind
  properties: {
    supportsHttpsTrafficOnly: storageConfig.httpsTrafficOnlyEnabled
    accessTier: storageConfig.accessTier
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
  tags: {
    displayName: 'Array Storage Accounts'
  }
  location: item
  name: '${namestorage}${instName[i]}${nameConv.storageAccountName}'
}]

resource name_instName_nameConv_hostingPlanName 'Microsoft.Web/serverfarms@2021-03-01' = [for (item, i) in instLocation: {
  sku: {
    name: 'Y1'//Dynamic
  }
  location: item
  name: '${name}-${instName[i]}${nameConv.hostingPlanName}'
}]

resource name_instName_nameConv_siteName 'Microsoft.Web/sites@2020-12-01' = [for (item, i) in instLocation: {
  name: '${name}-${instName[i]}${nameConv.siteName}'
  location: item
  tags: {
    displayName: 'Array Sites'
  }
  kind: 'functionapp'
  properties: {
    httpsOnly: true
    serverFarmId: resourceId('Microsoft.Web/serverfarms', '${name}-${instName[i]}${nameConv.hostingPlanName}')
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${namestorage}${instName[i]}${nameConv.storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(namestorage_instName_nameConv_storageAccountName[i].id, namestorage_instName_nameConv_storageAccountName[i].apiVersion).keys[0].value}'
        }
        // {
        //   name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        //   value: 'DefaultEndpointsProtocol=https;AccountName=$${namestorage}${instName[i]}${nameConv.storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(namestorage_instName_nameConv_storageAccountName[i].id, namestorage_instName_nameConv_storageAccountName[i].apiVersion).keys[0].value}'
        // }

        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: name_global_nameConv_appins.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${name_global_nameConv_appins.properties.InstrumentationKey}'
        }
      ]
    }
  }

}]

// resource function 'Microsoft.Web/sites/functions@2020-12-01' = {
//   name: '${functionApp.name}/${functionNameComputed}'
//   properties: {
//     config: {
//       disabled: false
//       bindings: [
//         {
//           name: 'req'
//           type: 'httpTrigger'
//           direction: 'in'
//           authLevel: 'function'
//           methods: [
//             'get'
//           ]
//         }
//         {
//           name: '$return'
//           type: 'http'
//           direction: 'out'
//         }
//       ]
//     }
//     files: {
//       'run.csx': loadTextContent('run.csx')
//     }
//   }
// }


// resource name_global_nameConv_trafficManagerName 'Microsoft.Network/trafficManagerProfiles@2015-11-01' = {
//   location: 'global'
//   properties: {
//     profileStatus: 'Enabled'
//     trafficRoutingMethod: 'Performance'
//     dnsConfig: {
//       relativeName: '${name}-global-${nameConv.trafficManagerName}'
//       ttl: 30
//     }
//     monitorConfig: {
//       protocol: 'HTTPS'
//       port: 443
//       path: '/api/IsAlive'
//     }
//   }
//   name: '${name}-global-${nameConv.trafficManagerName}'
// }


resource trafficManagerProfile 'Microsoft.Network/trafficManagerProfiles@2018-08-01' = {
  name: '${name}-global-${nameConv.trafficManagerName}'
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: '${name}-global-${nameConv.trafficManagerName}'
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/api/IsAlive'
    }
    // endpoints: [for endpoint in trafficManagerProfile.endpoints: {
    //   type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
    //   id: '${resourceId('Microsoft.Network/trafficManagerProfiles', trafficManagerConfig.name)}/externalEndpoints/${endpoint.name}'
    //   name: endpoint.name
    //   properties: {
    //     endpointStatus: 'Enabled'
    //     target: endpoint.target
    //   }
    // }]
    // endpoints: [
    //   {
    //     name: uniqueDnsNameForWebApp
    //     type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
    //     properties: {
    //       targetResourceId: webSite.id
    //       endpointStatus: 'Enabled'
    //     }
    //   }
    // ]
  }
}


resource name_global_nameConv_appins 'Microsoft.Insights/components@2020-02-02' = {
  name: '${name}-global-${nameConv.appins}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
//   name: keyVaultName
//   location: location
//   properties: {
//     tenantId: subscription().tenantId
//     sku: {
//       family: 'A'
//       name: keyVaultSku
//     }
//     accessPolicies: []
//   }
// }

// resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
//   name: '${keyVault.name}/${functionAppKeySecretName}'
//   properties: {
//     value: listKeys('${functionApp.id}/host/default', functionApp.apiVersion).functionKeys.default
//   }
// }

// output functionAppHostName string = functionApp.properties.defaultHostName
// output functionName string = functionNameComputed
