locals {
  firewall_spec = {
    name       = var.name
    network_id = var.network_id
    rules      = var.rules
    tags       = var.tags
  }
}
