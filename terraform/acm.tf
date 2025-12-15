// Create certficat for our domain
resource "aws_acm_certificate" "CA_https" {
  domain_name       = local.primary_domain
  subject_alternative_names = [local.secondary_domains]
  validation_method = "DNS"

  tags = {
    Name        = "CA for HTTPS"
    Environment = "Dev"
  }
}

// Certificate validation
data "aws_route53_zone" "main" {
  name         = local.primary_domain
  private_zone = false
}

resource "aws_route53_record" "CA_record" {
  for_each = {
    for dvo in aws_acm_certificate.CA_https.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 90
}

resource "aws_acm_certificate_validation" "CA_validation" {
  certificate_arn = aws_acm_certificate.CA_https.arn
  validation_record_fqdns = [for record in aws_route53_record.CA_record : record.fqdn]
}
