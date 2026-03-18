output "dns_spec" {
  description = "Provider-agnostic desired DNS spec for implementation or manual provisioning."
  value       = local.dns_spec
}

output "dns_zone_id" {
  description = "Logical DNS zone identifier for downstream modules."
  value       = "dns/${var.zone}"
}
