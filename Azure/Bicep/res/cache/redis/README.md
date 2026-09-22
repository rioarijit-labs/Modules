# Redis Cache

Azure Cache for Redis. Wraps `br/public:avm/res/cache/redis:0.18.0`.

## Defaults

- **Standard** tier, private access, access keys **disabled** — Entra ID only
- TLS 1.2 minimum, non-SSL port disabled

## Tier trade-off

Private endpoints exist on every tier, but VNet injection and clustering (`shardCount`) need Premium. Basic has no replica and no SLA — fine for a dev cache, not for anything with real traffic. Standard is the default here because it adds the replica with almost no cost difference from Basic.

## Access without keys

With `disableAccessKeyAuthentication` on (the default), applications authenticate with Entra ID tokens rather than an access key. Grant access with `roleAssignments`, for example `Redis Cache Contributor` for management operations. Redis data-plane access control (`ACL` style permissions on keys) is configured separately through the cache's own access policies if you need finer-grained data access than "has Entra ID token."

## Usage

```bicep
module cache '../../res/cache/redis/main.bicep' = {
  name: 'cache'
  params: {
    name: 'redis-sessions-001'
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[1]
    privateDnsZoneResourceIds: [redisZone.outputs.resourceId]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.test.bicep): private endpoint and a contributor role assignment
