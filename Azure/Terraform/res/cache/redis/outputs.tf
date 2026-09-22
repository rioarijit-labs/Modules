output "resource_id" {
  description = "Resource ID of the cache."
  value       = module.redis.resource_id
}

output "name" {
  description = "Name of the cache."
  value       = var.name
}

output "host_name" {
  description = "Host name to connect to, e.g. <name>.redis.cache.windows.net."
  value       = "${var.name}.redis.cache.windows.net"
}

output "ssl_port" {
  description = "SSL port. Always 6380 for Azure Cache for Redis."
  value       = 6380
}
