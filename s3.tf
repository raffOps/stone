resource "aws_s3_bucket" "bucket" {
  for_each = toset(var.lambda_bucket_name)
    bucket = each.value
    force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  for_each = toset(var.lambda_bucket_name)
    bucket = each.value
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  depends_on = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket" "bucket_database" {
  bucket = "divida-database"
  force_destroy = true
}


resource "aws_s3_bucket_public_access_block" "bucket_database_block" {
  bucket = "divida-database"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [aws_s3_bucket.bucket_database]
}