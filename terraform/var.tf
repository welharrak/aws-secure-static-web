variable "dns_domain_name" {
  type        = string
  description = "Domain name for the CloudFront distribution"
  default     = "example-secure-web.com"
}

variable "www_domain_name" {
  type        = string
  description = "Subdomain name for the CloudFront distribution"
  default     = "www.example-secure-web.com"
}

variable "enable_dns" {
  type    = bool
  default = false
}