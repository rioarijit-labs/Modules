metadata name = 'Storage account - defaults'
metadata description = 'Minimum viable deployment: secure defaults only, no private endpoint.'

module test '../../main.bicep' = {
  name: 'test-storage-defaults'
  params: {
    name: 'stdefaults${uniqueString(resourceGroup().id)}'
  }
}
