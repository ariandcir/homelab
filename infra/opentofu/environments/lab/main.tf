module "cluster_interface" {
  source = "../../modules/cluster_interface"

  cluster_name       = var.cluster_name
  control_plane_cidr = var.control_plane_cidr
  worker_cidr        = var.worker_cidr

  # TODO: Keep false until a provider API is confirmed stable.
  enable_unstable_provider_resources = false
}
