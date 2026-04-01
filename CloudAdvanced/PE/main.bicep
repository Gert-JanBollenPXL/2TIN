param loadBalancers_lb_checkapp_name string = 'lb-checkapp'
param virtualMachines_vm_backend_name string = 'vm-backend'
param virtualMachines_vm_frontend_name string = 'vm-frontend'
param sshPublicKeys_vm_backend_key_name string = 'vm-backend_key'
param bastionHosts_bastion_checkapp_name string = 'bastion-checkapp'
param virtualNetworks_vnet_checkapp_name string = 'vnet-checkapp'
param publicIPAddresses_pip_frontend_name string = 'pip-frontend'
param networkInterfaces_vm_backend714_name string = 'vm-backend714'
param networkInterfaces_nic_vm_frontend_name string = 'nic-vm-frontend'
param networkSecurityGroups_nsg_backend_name string = 'nsg-backend'
param networkSecurityGroups_nsg_frontend_name string = 'nsg-frontend'
param applicationSecurityGroups_asg_frontend_name string = 'asg-frontend'
param publicIPAddresses_pip_bastion_checkapp_name string = 'pip-bastion-checkapp'
param schedules_shutdown_computevm_vm_backend_name string = 'shutdown-computevm-vm-backend'

resource sshPublicKeys_vm_backend_key_name_resource 'Microsoft.Compute/sshPublicKeys@2025-04-01' = {
  name: sshPublicKeys_vm_backend_key_name
  location: 'northeurope'
  properties: {
    publicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2VDB74966Rcg6ueBv38kKvHFnFf25Jft2mI0XoNmgW7OSb0o3UPftRs0oC8MuZRE0nAUSi9FdRQwNu3ewb8WSM/YG1p/sRbfwgHKU/98ZqCXMqfnOFzPrt8loIkmYSOp2a2fruHF0yEQjL8rRkCm5NsSFjBpcb5Zt9MLU+VZHS0WMEtABU4HdWDVynjyYe2jbl37LalX8J/14fdSpIfqPvDO9CnrUbGPpP1XrvvNdL09HCeWYXwCWUfzg32asOjC1wgwSVUmh5pmV8ztGdoF0s1bDKxY4V4ItfIyGufKHcUvqHsQLTBV1UlPQSk4hkpmFpG/vy6bvy5LXqrsatwva+ULLppL3Luat1h9/TggSaKGqzSEoIct+lKi8v+p9K6MWOMhrzBUKn14IJjOj6kRUWGUCYf9d8rucF383PViP7cZ+Rk49NgEEe7uWmlrsUvZffdT38f3JdsbCU9KWNYZ4kSedc1meGmeANWaBrA0cYlIv9gcqiB5kI4GbjS1tMt0= generated-by-azure'
  }
}

resource applicationSecurityGroups_asg_frontend_name_resource 'Microsoft.Network/applicationSecurityGroups@2024-07-01' = {
  name: applicationSecurityGroups_asg_frontend_name
  location: 'northeurope'
  properties: {}
}

resource networkSecurityGroups_nsg_frontend_name_resource 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: networkSecurityGroups_nsg_frontend_name
  location: 'northeurope'
  properties: {
    securityRules: [
      {
        name: 'AllowHttp80FromInternet'
        id: networkSecurityGroups_nsg_frontend_name_AllowHttp80FromInternet.id
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource publicIPAddresses_pip_bastion_checkapp_name_resource 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: publicIPAddresses_pip_bastion_checkapp_name
  location: 'northeurope'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    ipAddress: '20.105.39.25'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource publicIPAddresses_pip_frontend_name_resource 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: publicIPAddresses_pip_frontend_name
  location: 'northeurope'
  tags: {
    bicepcreated: 'true'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '128.251.3.127'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
  }
}

resource virtualMachines_vm_backend_name_resource 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: virtualMachines_vm_backend_name
  location: 'northeurope'
  zones: [
    '3'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ts_v2'
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_vm_backend_name}_disk1_ecc7d9524fff4e5fb1d89e86f2c901f5'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          id: resourceId(
            'Microsoft.Compute/disks',
            '${virtualMachines_vm_backend_name}_disk1_ecc7d9524fff4e5fb1d89e86f2c901f5'
          )
        }
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachines_vm_backend_name
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2VDB74966Rcg6ueBv38kKvHFnFf25Jft2mI0XoNmgW7OSb0o3UPftRs0oC8MuZRE0nAUSi9FdRQwNu3ewb8WSM/YG1p/sRbfwgHKU/98ZqCXMqfnOFzPrt8loIkmYSOp2a2fruHF0yEQjL8rRkCm5NsSFjBpcb5Zt9MLU+VZHS0WMEtABU4HdWDVynjyYe2jbl37LalX8J/14fdSpIfqPvDO9CnrUbGPpP1XrvvNdL09HCeWYXwCWUfzg32asOjC1wgwSVUmh5pmV8ztGdoF0s1bDKxY4V4ItfIyGufKHcUvqHsQLTBV1UlPQSk4hkpmFpG/vy6bvy5LXqrsatwva+ULLppL3Luat1h9/TggSaKGqzSEoIct+lKi8v+p9K6MWOMhrzBUKn14IJjOj6kRUWGUCYf9d8rucF383PViP7cZ+Rk49NgEEe7uWmlrsUvZffdT38f3JdsbCU9KWNYZ4kSedc1meGmeANWaBrA0cYlIv9gcqiB5kI4GbjS1tMt0= generated-by-azure'
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vm_backend714_name_resource.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource virtualMachines_vm_frontend_name_resource 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: virtualMachines_vm_frontend_name
  location: 'northeurope'
  tags: {
    bicepcreated: 'true'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ts_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_vm_frontend_name}_disk1_b0e418eae0cb4f36b4b2564a4a1700a1'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          id: resourceId(
            'Microsoft.Compute/disks',
            '${virtualMachines_vm_frontend_name}_disk1_b0e418eae0cb4f36b4b2564a4a1700a1'
          )
        }
        deleteOption: 'Detach'
        diskSizeGB: 30
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachines_vm_frontend_name
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_nic_vm_frontend_name_resource.id
        }
      ]
    }
  }
}

resource schedules_shutdown_computevm_vm_backend_name_resource 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: schedules_shutdown_computevm_vm_backend_name
  location: 'northeurope'
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'UTC'
    notificationSettings: {
      status: 'Enabled'
      timeInMinutes: 30
      emailRecipient: '12401891@student.pxl.be'
      notificationLocale: 'en'
    }
    targetResourceId: virtualMachines_vm_backend_name_resource.id
  }
}

resource loadBalancers_lb_checkapp_name_resource 'Microsoft.Network/loadBalancers@2024-07-01' = {
  name: loadBalancers_lb_checkapp_name
  location: 'northeurope'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'pip-frontend'
        id: '${loadBalancers_lb_checkapp_name_resource.id}/frontendIPConfigurations/pip-frontend'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_frontend_name_resource.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'frontend-checkapp'
        id: loadBalancers_lb_checkapp_name_frontend_checkapp.id
        properties: {
          loadBalancerBackendAddresses: [
            {
              name: 'PEGert-JanBollen_nic-vm-frontendipconfig1'
              properties: {}
            }
          ]
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'http-inbound'
        id: '${loadBalancers_lb_checkapp_name_resource.id}/loadBalancingRules/http-inbound'
        properties: {
          frontendIPConfiguration: {
            id: '${loadBalancers_lb_checkapp_name_resource.id}/frontendIPConfigurations/pip-frontend'
          }
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'Tcp'
          enableTcpReset: false
          loadDistribution: 'Default'
          disableOutboundSnat: true
          enableConnectionTracking: false
          backendAddressPool: {
            id: loadBalancers_lb_checkapp_name_frontend_checkapp.id
          }
          backendAddressPools: [
            {
              id: loadBalancers_lb_checkapp_name_frontend_checkapp.id
            }
          ]
          probe: {
            id: '${loadBalancers_lb_checkapp_name_resource.id}/probes/http-healthcheck-frontend'
          }
        }
      }
    ]
    probes: [
      {
        name: 'http-healthcheck-frontend'
        id: '${loadBalancers_lb_checkapp_name_resource.id}/probes/http-healthcheck-frontend'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 1
          probeThreshold: 1
          noHealthyBackendsBehavior: 'AllProbedDown'
        }
      }
    ]
    inboundNatRules: []
    outboundRules: []
    inboundNatPools: []
  }
}

resource loadBalancers_lb_checkapp_name_frontend_checkapp 'Microsoft.Network/loadBalancers/backendAddressPools@2024-07-01' = {
  name: '${loadBalancers_lb_checkapp_name}/frontend-checkapp'
  properties: {
    loadBalancerBackendAddresses: [
      {
        name: 'PEGert-JanBollen_nic-vm-frontendipconfig1'
        properties: {}
      }
    ]
  }
  dependsOn: [
    loadBalancers_lb_checkapp_name_resource
  ]
}

resource networkSecurityGroups_nsg_backend_name_resource 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: networkSecurityGroups_nsg_backend_name
  location: 'northeurope'
  properties: {
    securityRules: [
      {
        name: 'AllowSSH-from-bastion-to-backend'
        id: networkSecurityGroups_nsg_backend_name_AllowSSH_from_bastion_to_backend.id
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '172.16.90.0/24'
          destinationAddressPrefix: '172.16.2.0/24'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowTCP-from-backend-to-db'
        id: networkSecurityGroups_nsg_backend_name_AllowTCP_from_backend_to_db.id
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '5432'
          sourceAddressPrefix: '172.16.2.0/24'
          destinationAddressPrefix: '172.16.3.0/24'
          access: 'Allow'
          priority: 1001
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowTCP-from-frontend-to-backend'
        id: networkSecurityGroups_nsg_backend_name_AllowTCP_from_frontend_to_backend.id
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3000'
          destinationAddressPrefix: '172.16.2.0/24'
          access: 'Allow'
          priority: 1011
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
          sourceApplicationSecurityGroups: [
            {
              id: applicationSecurityGroups_asg_frontend_name_resource.id
            }
          ]
        }
      }
    ]
  }
}

resource networkSecurityGroups_nsg_frontend_name_AllowHttp80FromInternet 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = {
  name: '${networkSecurityGroups_nsg_frontend_name}/AllowHttp80FromInternet'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 1000
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_nsg_frontend_name_resource
  ]
}

resource networkSecurityGroups_nsg_backend_name_AllowSSH_from_bastion_to_backend 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = {
  name: '${networkSecurityGroups_nsg_backend_name}/AllowSSH-from-bastion-to-backend'
  properties: {
    protocol: 'TCP'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '172.16.90.0/24'
    destinationAddressPrefix: '172.16.2.0/24'
    access: 'Allow'
    priority: 1000
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_nsg_backend_name_resource
  ]
}

resource networkSecurityGroups_nsg_backend_name_AllowTCP_from_backend_to_db 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = {
  name: '${networkSecurityGroups_nsg_backend_name}/AllowTCP-from-backend-to-db'
  properties: {
    protocol: 'TCP'
    sourcePortRange: '*'
    destinationPortRange: '5432'
    sourceAddressPrefix: '172.16.2.0/24'
    destinationAddressPrefix: '172.16.3.0/24'
    access: 'Allow'
    priority: 1001
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_nsg_backend_name_resource
  ]
}

resource virtualNetworks_vnet_checkapp_name_resource 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: virtualNetworks_vnet_checkapp_name
  location: 'northeurope'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'
      ]
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        name: 'snet-frontend'
        id: virtualNetworks_vnet_checkapp_name_snet_frontend.id
        properties: {
          addressPrefix: '172.16.1.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroups_nsg_frontend_name_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: true
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'snet-database'
        id: virtualNetworks_vnet_checkapp_name_snet_database.id
        properties: {
          addressPrefix: '172.16.3.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: false
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'snet-backend'
        id: virtualNetworks_vnet_checkapp_name_snet_backend.id
        properties: {
          addressPrefix: '172.16.2.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: true
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'AzureBastionSubnet'
        id: virtualNetworks_vnet_checkapp_name_AzureBastionSubnet.id
        properties: {
          addressPrefix: '172.16.90.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource virtualNetworks_vnet_checkapp_name_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworks_vnet_checkapp_name}/AzureBastionSubnet'
  properties: {
    addressPrefix: '172.16.90.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_vnet_checkapp_name_resource
  ]
}

resource virtualNetworks_vnet_checkapp_name_snet_backend 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworks_vnet_checkapp_name}/snet-backend'
  properties: {
    addressPrefix: '172.16.2.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: true
  }
  dependsOn: [
    virtualNetworks_vnet_checkapp_name_resource
  ]
}

resource virtualNetworks_vnet_checkapp_name_snet_database 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworks_vnet_checkapp_name}/snet-database'
  properties: {
    addressPrefix: '172.16.3.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
  dependsOn: [
    virtualNetworks_vnet_checkapp_name_resource
  ]
}

resource bastionHosts_bastion_checkapp_name_resource 'Microsoft.Network/bastionHosts@2024-07-01' = {
  name: bastionHosts_bastion_checkapp_name
  location: 'northeurope'
  sku: {
    name: 'Basic'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    dnsName: 'bst-2b0e1a69-0f85-48de-b650-dd1973589294.bastion.azure.com'
    scaleUnits: 2
    enableTunneling: false
    enableIpConnect: false
    disableCopyPaste: false
    enableShareableLink: false
    enableKerberos: false
    enableSessionRecording: false
    enablePrivateOnlyBastion: false
    ipConfigurations: [
      {
        name: 'IpConf'
        id: '${bastionHosts_bastion_checkapp_name_resource.id}/bastionHostIpConfigurations/IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_bastion_checkapp_name_resource.id
          }
          subnet: {
            id: virtualNetworks_vnet_checkapp_name_AzureBastionSubnet.id
          }
        }
      }
    ]
  }
}

resource networkInterfaces_vm_backend714_name_resource 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: networkInterfaces_vm_backend714_name
  location: 'northeurope'
  kind: 'Regular'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        id: '${networkInterfaces_vm_backend714_name_resource.id}/ipConfigurations/ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '172.16.2.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetworks_vnet_checkapp_name_snet_backend.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    disableTcpStateTracking: false
    networkSecurityGroup: {
      id: networkSecurityGroups_nsg_backend_name_resource.id
    }
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}

resource networkSecurityGroups_nsg_backend_name_AllowTCP_from_frontend_to_backend 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = {
  name: '${networkSecurityGroups_nsg_backend_name}/AllowTCP-from-frontend-to-backend'
  properties: {
    protocol: 'TCP'
    sourcePortRange: '*'
    destinationPortRange: '3000'
    destinationAddressPrefix: '172.16.2.0/24'
    access: 'Allow'
    priority: 1011
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
    sourceApplicationSecurityGroups: [
      {
        id: applicationSecurityGroups_asg_frontend_name_resource.id
      }
    ]
  }
  dependsOn: [
    networkSecurityGroups_nsg_backend_name_resource
  ]
}

resource virtualNetworks_vnet_checkapp_name_snet_frontend 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworks_vnet_checkapp_name}/snet-frontend'
  properties: {
    addressPrefix: '172.16.1.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroups_nsg_frontend_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: true
  }
  dependsOn: [
    virtualNetworks_vnet_checkapp_name_resource
  ]
}

resource networkInterfaces_nic_vm_frontend_name_resource 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: networkInterfaces_nic_vm_frontend_name
  location: 'northeurope'
  kind: 'Regular'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        id: '${networkInterfaces_nic_vm_frontend_name_resource.id}/ipConfigurations/ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '172.16.1.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetworks_vnet_checkapp_name_snet_frontend.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
          applicationSecurityGroups: [
            {
              id: applicationSecurityGroups_asg_frontend_name_resource.id
            }
          ]
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancers_lb_checkapp_name_frontend_checkapp.id
            }
          ]
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    disableTcpStateTracking: false
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}
