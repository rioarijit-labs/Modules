# Container instance

A group of containers on Azure Container Instances, no orchestrator. Wraps `br/public:avm/res/container-instance/container-group:0.7.1`.

## Defaults

- **No public IP.** The group gets a private IP inside the subnet you pass; there is no concept of a private endpoint here, the resource itself lives in the VNet.
- `restartPolicy` defaults to `Always` (a long-running process); set it to `Never` for a one-off job or `OnFailure` for a retryable task.

## Scope

This module has no `roleAssignments` or `diagnosticsWorkspaceResourceId` parameter: the underlying AVM module (0.7.1) doesn't expose either. Send container logs to Log Analytics with `logAnalyticsWorkspaceResourceId` instead — that wires the container group's own log driver, which is a different mechanism from a diagnostic setting.

## Multiple containers

Containers in the same group share a network namespace and can reach each other over `localhost`. This is the sidecar pattern (e.g. an app container plus a log-shipping sidecar), not a way to run unrelated workloads together — unrelated jobs should be separate container groups.

## Usage

```bicep
module job '../../res/container-instance/container-group/main.bicep' = {
  name: 'job'
  params: {
    name: 'aci-nightly-import'
    subnetResourceId: vnet.outputs.subnetResourceIds[0]
    restartPolicy: 'Never'
    containers: [
      {
        name: 'import'
        image: '${registry.outputs.loginServer}/import-job:1.0.0'
        cpuCores: 1
        memoryInGB: 2
        environmentVariables: {
          TARGET_DATE: 'today'
        }
      }
    ]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): a one-off job with plain and secret environment variables
