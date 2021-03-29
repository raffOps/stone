resource "aws_s3_bucket" "sgs_estagio_1" {
  bucket = var.s3_bucket_name.sgs_estagio_1
  acl    = "private"
}

resource "aws_s3_bucket" "sgs_estagio_2" {
  bucket = var.s3_bucket_name.sgs_estagio_2
  acl    = "private"
}