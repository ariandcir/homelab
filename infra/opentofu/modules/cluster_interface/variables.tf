variable "cluster_name" {
  description = "Logical cluster name used by downstream modules and integrations."
  type        = string
}

variable "control_plane_cidr" {
  description = "CIDR allocated for control plane nodes."
  type        = string
}

variable "worker_cidr" {
  description = "CIDR allocated for worker nodes."
  type        = string
}

variable "enable_unstable_provider_resources" {
  description = "Feature flag to guard resources from immature provider APIs. Keep false in v1."
  type        = bool
  default     = false
}
