variable "global_tags" {
  description = "Tags applied across all module specs."
  type        = map(string)
  default     = {}
}

variable "network" {
  description = "Network intent for production."
  type = object({
    name    = string
    cidr    = string
    subnets = map(object({
      cidr = string
      az   = string
      tags = optional(map(string), {})
    }))
  })
}

variable "firewall" {
  description = "Firewall intent for production."
  type = object({
    name  = string
    rules = list(object({
      name        = string
      action      = string
      protocol    = string
      source_cidr = string
      destination = string
      ports       = list(string)
      direction   = string
      priority    = number
    }))
  })
}

variable "dns" {
  description = "DNS intent for production."
  type = object({
    zone = string
    records = map(object({
      type    = string
      ttl     = number
      values  = list(string)
      comment = optional(string, "")
    }))
  })
}

variable "vms" {
  description = "VM intent for production."
  type = map(object({
    image            = string
    size             = string
    subnet           = string
    assign_public_ip = optional(bool, false)
    firewall_policy  = optional(string, "")
    tags             = optional(map(string), {})
    metadata         = optional(map(string), {})
    startup_script   = optional(string, "")
  }))
  default = {}
}
