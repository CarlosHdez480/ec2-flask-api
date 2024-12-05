
resource "aws_s3_bucket" "bucket_s3" {
  bucket = var.bucket_backend
}

resource "aws_s3_bucket_public_access_block" "bucket_s3_acl_block" {
  bucket                  = aws_s3_bucket.bucket_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

