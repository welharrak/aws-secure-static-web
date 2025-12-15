// Create OAC to enable access to S3 buckt from our CloudFront distribution
resource "aws_cloudfront_origin_access_control" "origin_oac" {
  name                              = "oac-static-web"
  description                       = "OAC for private origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

// Create cdn distribution
resource "aws_cloudfront_distribution" "cdn" {
  // Set Origin
  origin {
    domain_name              = aws_s3_bucket.origin_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_oac.id
    origin_id                = local.s3-origin
  }

  // Options
  enabled             = true
  default_root_object = "index.html"

  aliases = local.secondary_domains

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3-origin

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600  // 1 hour
    max_ttl                = 86400 // 24 hours
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.CA_https.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019" // 2019 to allow old browsers
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

// Create aliases from domain to CloudFront Distribution
resource "aws_route53_record" "cdn_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.primary_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_cdn_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.www_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

