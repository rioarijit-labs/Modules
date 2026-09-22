# Redis Cache

Azure Cache for Redis. Wraps `Azure/avm-res-cache-redis/azurerm` 0.4.0.

## Defaults

- **Standard** tier, private access, access keys **disabled** — Entra ID only
- TLS 1.2 minimum, non-SSL port disabled

## Tier trade-off

Private endpoints exist on every tier, but VNet injection and clustering (`shard_count`) need Premium. Basic has no replica and no SLA — fine for a dev cache, not for anything with real traffic. Standard is the default here because it adds the replica with almost no cost difference from Basic.

## Access without keys

With `access_keys_authentication_enabled` off (the default), applications authenticate with Entra ID tokens rather than an access key. Grant access with `role_assignments`, for example `Redis Cache Contributor` for management operations.

## Usage

```hcl
module "cache" {
  source = "../../res/cache/redis"

  name              = "redis-sessions-001"
  location          = "westeurope"
  resource_group_id = azurerm_resource_group.this.id

  private_endpoint = {
    subnet_resource_id            = module.network.subnet_resource_ids["private_endpoints"]
    private_dns_zone_resource_ids = [module.redis_zone.resource_id]
  }
}
```

## Tests

- [tests/defaults](tests/defaults/main.tf): private endpoint and a contributor role assignment
