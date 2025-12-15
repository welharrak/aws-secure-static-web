// Create S3 bucket where Static Web will be hosted
resource "aws_s3_bucket" "origin_bucket" {
  bucket = "s3-origin-bucket-14-12-2025"

  tags = {
    Name        = "Origin Bucket"
    Environment = "Dev"
  }
}

// Make S3 bucket totally private, with no public access
resource "aws_s3_bucket_public_access_block" "origin_bucket" {
  bucket = aws_s3_bucket.origin_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// Enable versioning in S3 bucket
resource "aws_s3_bucket_versioning" "origin_bucket" {
  bucket = aws_s3_bucket.origin_bucket.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Enabled"
  }
}

// Create bucket policy to enbale access to cdn distribution
data "aws_iam_policy_document" "allow_access_to_cdn" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.origin_bucket.arn}/*"
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.cdn.arn]
    }
  }

}

resource "aws_s3_bucket_policy" "allow_access_to_cdn" {
  bucket = aws_s3_bucket.origin_bucket.id
  policy = data.aws_iam_policy_document.allow_access_to_cdn.json

}

