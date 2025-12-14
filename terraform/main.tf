provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "origin_bucket" {
  bucket = "s3-origin-bucket-14-12-2025"

  tags = {
    Name        = "Origin Bucket"
    Environment = "Dev"
  }
}