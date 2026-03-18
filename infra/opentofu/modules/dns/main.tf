locals {
  dns_spec = {
    zone    = var.zone
    records = var.records
    tags    = var.tags
  }
}
