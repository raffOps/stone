resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test_lambda" {
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "sgs-extract.lambda_handler"
  runtime = "python3.8"
  image_uri     = aws_ecr_repository.repo.repository_url
  package_type = "Image"


  image_config {
    command = ["sgs-extract.lambda_handler"]
  }
  environment {
    variables = {
      foo = "bar"
    }
  }

  depends_on = [aws_ecr_repository.repo]
}