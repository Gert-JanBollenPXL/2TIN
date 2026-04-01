param location string = resourceGroup().location

@secure()
param adminPassword string
param adminUsername string = 'azureuser'


param winPrivateVmName string = 'win-private'
param winPublicVmName string = 'win-public'
param winVmSize string = 'Standard_B2ls_v2'

param otherLinuxVmName string = 'linux-other'
param otherLinuxVmSize string = 'Standard_B2ts_v2'

param vnetName string = 'vnet-nsglab'
param vnetAddressPrefix string = '10.1.0.0/16'
param privateSubnetName string = 'snet-private'
param privateSubnetPrefix string = '10.1.10.0/24'
param publicSubnetName string = 'snet-public'
param publicSubnetPrefix string = '10.1.20.0/24'
param nsgName string = 'nsg-subnets'
param nsgOtherName string ='nsg-othervnet'
param otherVnetName string = 'vnet-other'
param otherVnetAddressPrefix string = '10.2.0.0/16'
param otherSubnetName string = 'snet-other'
param otherSubnetPrefix string = '10.2.10.0/24'

// ----------------------
// Network Resources
// ----------------------
resource nsgSubnets 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: []
  }
}

resource nsgOtherVnet 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: nsgOtherName
  location: location
  properties: {
    securityRules: []
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: privateSubnetName
        properties: {
          addressPrefix: privateSubnetPrefix
          networkSecurityGroup: {
            id: nsgSubnets.id
          }
        }
      }
      {
        name: publicSubnetName
        properties: {
          addressPrefix: publicSubnetPrefix
          networkSecurityGroup: {
            id: nsgSubnets.id
          }
        }
      }
    ]
  }
}

resource otherVnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: otherVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        otherVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: otherSubnetName
        properties: {
          addressPrefix: otherSubnetPrefix
          networkSecurityGroup: {
            id: nsgOtherVnet.id
          }
        }
      }
    ]
  }
}

// ----------------------
// NIC Resources
// ----------------------
resource winPrivateNic 'Microsoft.Network/networkInterfaces@2025-05-01' = {
  name: 'nic-${winPrivateVmName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource winPublicNic 'Microsoft.Network/networkInterfaces@2025-05-01' = {
  name: 'nic-${winPublicVmName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[1].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource otherLinuxNic 'Microsoft.Network/networkInterfaces@2025-05-01' = {
  name: 'nic-${otherLinuxVmName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: otherVnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// ----------------------
// Windows VM Resources
// ----------------------
resource winPrivateVm 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: 'vm-${winPrivateVmName}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: winVmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2025-datacenter-smalldisk-g2'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: winPrivateVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: winPrivateNic.id
        }
      ]
    }
  }
}

resource winPublicVm 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: 'vm-${winPublicVmName}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: winVmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2025-datacenter-smalldisk-g2'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: winPublicVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: winPublicNic.id
        }
      ]
    }
  }
}

resource otherLinuxVm 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: 'vm-${otherLinuxVmName}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: otherLinuxVmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: otherLinuxVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: base64('''
#cloud-config
package_update: true
packages:
  - nginx
runcmd:
  - systemctl enable --now nginx
''')
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: otherLinuxNic.id
        }
      ]
    }
  }
}
