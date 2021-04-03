resource "aws_iam_role" "iam_lambda" {
  name = "iam_lambda"

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

resource "aws_iam_role_policy_attachment" "lambda_S3_role_attach" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

resource "aws_iam_role" "iam_stf" {
  name = "iam_stf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "stf_lambda" {
  name = "stf_lambda_acess"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "arn:aws:lambda:us-east-1:*:function:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "stf_lambda_role_attach" {
  role       = aws_iam_role.iam_stf.name
  policy_arn = aws_iam_policy.stf_lambda.arn
}


resource "aws_iam_policy" "stf_xray" {
  name = "stf_xray_acess"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "stf_xray_role_attach" {
  role       = aws_iam_role.iam_stf.name
  policy_arn = aws_iam_policy.stf_xray.arn
}



