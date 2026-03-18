output "vm_spec" {
  description = "Provider-agnostic desired VM spec for implementation or manual provisioning."
  value       = local.vm_spec
}

output "vm_ids" {
  description = "Logical VM identifiers keyed by instance name."
  value       = { for name, _ in var.instances : name => "vm/${name}" }
}
