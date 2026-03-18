output "network_spec" {
  description = "Provider-agnostic desired network spec for implementation or manual provisioning."
  value       = local.network_spec
}

output "network_id" {
  description = "Logical network identifier for downstream modules."
  value       = "network/${var.name}"
}
