locals {
  network_spec = {
    name    = var.name
    cidr    = var.cidr
    subnets = var.subnets
    tags    = var.tags
  }
}
