variable "zone" {
  description = "DNS zone name (for example: example.internal)."
  type        = string
}

variable "records" {
  description = "DNS records keyed by record name."
  type = map(object({
    type    = string
    ttl     = number
    values  = list(string)
    comment = optional(string, "")
  }))
  default = {}
}

variable "tags" {
  description = "Common tags for DNS scope."
  type        = map(string)
  default     = {}
}
