resource "aws_s3_bucket" "bucket" {
  for_each = var.lambda_bucket_name
    bucket = each.value
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  for_each = var.lambda_bucket_name
    bucket = each.value
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  depends_on = [aws_s3_bucket.bucket]
}