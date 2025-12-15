locals {
  primary_domain = var.dns_domain_name
  www_domain = var.www_domain_name
  secondary_domains = [
    var.dns_domain_name,
    var.www_domain_name

  ]

  s3-origin = "Private-S3-Origin"
}