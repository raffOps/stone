
#================= SGS ======================================================================
resource "aws_sfn_state_machine" "sgs" {
  name     = "sgs-pipeline"
  role_arn = aws_iam_role.iam_stf.arn
  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using Pass states",
  "StartAt": "Extract SGS",
  "States": {
    "Extract SGS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "sgs-extract:$LATEST"
      },
      "Next": "Extract SGS finished with sucess?"
    },
    "Extract SGS finished with sucess?": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Payload.status",
          "BooleanEquals": true,
          "Next": "Transform SGS"
        }
      ],
      "Default": "Fail"
    },
    "Transform SGS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "sgs-transform:$LATEST"
      },
      "Next": "Transform SGS finished with sucess?"
    },
    "Transform SGS finished with sucess?": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Payload.status",
          "BooleanEquals": true,
          "Next": "Finished with sucess"
        }
      ],
      "Default": "Fail"
    },
    "Finished with sucess": {
      "Type": "Pass",
      "End": true
    },
    "Fail": {
      "Type": "Fail",
      "Cause": "No Matches!"
    }
  }
}
EOF

  depends_on = [aws_lambda_function.lambda, aws_s3_bucket.bucket,
    aws_iam_role_policy_attachment.stf_lambda_role_attach, aws_iam_role_policy_attachment.lambda_S3_role_attach]
}


#================= SGS ======================================================================
resource "aws_sfn_state_machine" "sgs" {
  name     = "sgs-pipeline"
  role_arn = aws_iam_role.iam_stf.arn
  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using Pass states",
  "StartAt": "Extract SGS",
  "States": {
    "Extract SGS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "sgs-extract:$LATEST"
      },
      "Next": "Extract SGS finished with sucess?"
    },
    "Extract SGS finished with sucess?": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Payload.status",
          "BooleanEquals": true,
          "Next": "Transform SGS"
        }
      ],
      "Default": "Fail"
    },
    "Transform SGS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "sgs-transform:$LATEST"
      },
      "Next": "Transform SGS finished with sucess?"
    },
    "Transform SGS finished with sucess?": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Payload.status",
          "BooleanEquals": true,
          "Next": "Finished with sucess"
        }
      ],
      "Default": "Fail"
    },
    "Finished with sucess": {
      "Type": "Pass",
      "End": true
    },
    "Fail": {
      "Type": "Fail",
      "Cause": "No Matches!"
    }
  }
}
EOF

  depends_on = [aws_lambda_function.lambda, aws_s3_bucket.bucket,
    aws_iam_role_policy_attachment.stf_lambda_role_attach, aws_iam_role_policy_attachment.lambda_S3_role_attach]
}

