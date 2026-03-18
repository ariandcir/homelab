variable "name" {
  description = "Logical firewall policy name."
  type        = string
}

variable "network_id" {
  description = "Logical network identifier associated with this policy."
  type        = string
}

variable "rules" {
  description = "Ordered allow/deny rule definitions."
  type = list(object({
    name        = string
    action      = string
    protocol    = string
    source_cidr = string
    destination = string
    ports       = list(string)
    direction   = string
    priority    = number
  }))
  default = []
}

variable "tags" {
  description = "Common tags for firewall resources."
  type        = map(string)
  default     = {}
}
