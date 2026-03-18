variable "name" {
  description = "Logical network name."
  type        = string
}

variable "cidr" {
  description = "Primary network CIDR block."
  type        = string
}

variable "subnets" {
  description = "Subnet definitions keyed by logical subnet name."
  type = map(object({
    cidr = string
    az   = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Common tags for the network scope."
  type        = map(string)
  default     = {}
}
