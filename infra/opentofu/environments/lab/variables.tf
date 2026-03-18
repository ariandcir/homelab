variable "cluster_name" {
  type        = string
  description = "Lab cluster name."
  default     = "lab"
}

variable "control_plane_cidr" {
  type        = string
  description = "Control plane network CIDR."
  default     = "10.10.0.0/24"
}

variable "worker_cidr" {
  type        = string
  description = "Worker network CIDR."
  default     = "10.10.1.0/24"
}
