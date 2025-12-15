// Create trail for auditing
resource "aws_cloudtrail" "cdn_audit" {
    name = "secure-web-trail"
    s3_bucket_name = aws_s3_bucket.trail_bucket.id
    depends_on = [aws_s3_bucket.trail_bucket]
}

resource "aws_s3_bucket" "trail_bucket" {
  bucket = "s3-audit-bucket-14-12-2025"

  tags = {
    Name        = "Audit Bucket"
    Environment = "Dev"
  }
}

// Policies