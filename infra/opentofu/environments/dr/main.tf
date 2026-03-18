module "network" {
  source = "../../modules/network"

  name    = var.network.name
  cidr    = var.network.cidr
  subnets = var.network.subnets
  tags    = var.global_tags
}

module "firewall" {
  source = "../../modules/firewall"

  name       = var.firewall.name
  network_id = module.network.network_id
  rules      = var.firewall.rules
  tags       = var.global_tags
}

module "dns" {
  source = "../../modules/dns"

  zone    = var.dns.zone
  records = var.dns.records
  tags    = var.global_tags
}

module "vm" {
  source = "../../modules/vm"

  instances = {
    for vm_name, vm in var.vms :
    vm_name => merge(vm, {
      network_id      = module.network.network_id
      firewall_policy = coalesce(try(vm.firewall_policy, null), module.firewall.firewall_policy_id)
    })
  }
  tags = var.global_tags
}

output "manual_provisioning_specs" {
  description = "Specs an operator can follow for manual provisioning when no provider API exists."
  value = {
    network  = module.network.network_spec
    firewall = module.firewall.firewall_spec
    dns      = module.dns.dns_spec
    vm       = module.vm.vm_spec
  }
}
