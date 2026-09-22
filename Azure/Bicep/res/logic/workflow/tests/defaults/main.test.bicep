metadata name = 'Logic App - defaults'
metadata description = 'HTTP-triggered workflow with a single response action.'

module test '../../main.bicep' = {
  name: 'test-logic-workflow-defaults'
  params: {
    name: 'logic-defaults'
    triggers: {
      manual: {
        type: 'Request'
        kind: 'Http'
        inputs: {
          schema: {}
        }
      }
    }
    actions: {
      Response: {
        type: 'Response'
        kind: 'Http'
        inputs: {
          statusCode: 200
          body: 'OK'
        }
      }
    }
  }
}
