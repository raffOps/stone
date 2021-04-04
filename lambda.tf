resource "aws_lambda_function" "lambda" {
  for_each = toset(var.lambda_bucket_name)
    function_name = each.value
    #handler       = "${each.value}.lambda_handler"
    role          = aws_iam_role.iam_lambda.arn
    timeout = 900 #
    memory_size =  each.value == var.lambda_bucket_name[2] || each.value == var.lambda_bucket_name[3] ? 9000 : 1000
    image_uri     = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.service_image.image_digest}"
    #runtime       = "python3.8"
    package_type  = "Image"
      image_config {
      command = ["${each.value}.lambda_handler"]
    }
  environment {
    variables = {
      S3_BUCKET_NAME = each.value
    }
  }

    depends_on = [aws_ecr_repository.repo, data.aws_ecr_image.service_image]
}

