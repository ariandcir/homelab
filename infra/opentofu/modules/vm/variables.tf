variable "instances" {
  description = "VM instances keyed by logical instance name."
  type = map(object({
    image            = string
    size             = string
    network_id       = string
    subnet           = string
    assign_public_ip = optional(bool, false)
    firewall_policy  = optional(string, "")
    tags             = optional(map(string), {})
    metadata         = optional(map(string), {})
    startup_script   = optional(string, "")
  }))
  default = {}
}

variable "tags" {
  description = "Common tags for VM scope."
  type        = map(string)
  default     = {}
}
