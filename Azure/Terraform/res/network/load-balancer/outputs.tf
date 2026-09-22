output "resource_id" {
  description = "Resource ID of the load balancer."
  value       = module.load_balancer.resource_id
}

output "name" {
  description = "Name of the load balancer."
  value       = var.name
}
