resource "aws_cloudwatch_log_group" "stone" {
  name = "stone"
}
#================= SGS ======================================================================
resource "aws_sfn_state_machine" "sgs" {
  name     = "sgs-pipeline"
  role_arn = aws_iam_role.iam_stf.arn
//  logging_configuration {
//    log_destination        = "${aws_cloudwatch_log_group.stone.arn}:*"
//    include_execution_data = true
//    level                  = "ERROR"
//  }
  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using Pass states",
  "StartAt": "Extract SGS - CODES",
  "States": {
    "Extract SGS - CODES": {
      "Type": "Map",
      "InputPath": "$",
      "ItemsPath": "$.codigos",
      "Parameters": {
        "codigos.$": "$$.Map.Item.Value"
      },
      "ResultPath": "$.array",
      "MaxConcurrency": 4,
      "Next": "Transform SGS",
      "Iterator": {
        "StartAt": "Extract SGS",
        "States": {
          "Extract SGS": {
            "End": true,
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "FunctionName": "${var.lambda_bucket_name[0]}:$LATEST",
              "Payload": {
                "codigos.$": "$.codigos"
              }
            }
          }
        }
      }
    },
    "Transform SGS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${var.lambda_bucket_name[1]}:$LATEST"
      },
      "Next": "Finished with sucess"
    },
    "Finished with sucess": {
      "Type": "Pass",
      "End": true
    }
  }
}
EOF

  depends_on = [aws_lambda_function.lambda, aws_s3_bucket.bucket,
    aws_iam_role_policy_attachment.stf_lambda_role_attach, aws_iam_role_policy_attachment.lambda_S3_role_attach]
}


#================= PGFN ======================================================================
resource "aws_sfn_state_machine" "pgfn" {
  name     = "pgfn-pipeline"
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
    aws_iam_role_policy_attachment.stf_lambda_role_attach, aws_iam_role_policy_attachment.stf_xray_role_attach]
}

