output "firewall_spec" {
  description = "Provider-agnostic desired firewall spec for implementation or manual provisioning."
  value       = local.firewall_spec
}

output "firewall_policy_id" {
  description = "Logical firewall policy identifier for downstream modules."
  value       = "firewall/${var.name}"
}
