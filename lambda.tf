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

resource "aws_iam_policy" "lambda_s3" {
  name = "lambda_s3_acess"
  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:*"
        ],
        "Resource": "arn:aws:s3:::*"
    }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

resource "aws_lambda_function" "lambda" {
  for_each = var.lambda_bucket_name
    function_name = each.value
    #handler       = "${each.value}.lambda_handler"
    role          = aws_iam_role.iam_for_lambda.arn
    timeout = 840 # 14 minutos
    memory_size =  each.value == "pgfn-extract" ? 9000 : 1000
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

