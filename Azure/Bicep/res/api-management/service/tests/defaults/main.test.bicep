metadata name = 'API Management - defaults'
metadata description = 'Developer tier instance with one OpenAPI-imported API.'

module test '../../main.bicep' = {
  name: 'test-api-management-defaults'
  params: {
    name: 'apim-defaults-${take(uniqueString(resourceGroup().id), 8)}'
    publisherEmail: 'api-team@example.com'
    publisherName: 'Example Corp'
    apis: [
      {
        name: 'orders-api'
        displayName: 'Orders API'
        path: 'orders'
        openApiSpecUrl: 'https://example.com/openapi/orders.json'
      }
    ]
  }
}
