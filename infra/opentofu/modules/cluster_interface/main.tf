# Provider-agnostic interface module.
# TODO: Replace null_resource with stable provider resources per selected provider.
resource "null_resource" "cluster_interface" {
  triggers = {
    cluster_name      = var.cluster_name
    control_plane_cidr = var.control_plane_cidr
    worker_cidr        = var.worker_cidr
  }
}
