#================= SGS ======================================================================
resource "aws_sfn_state_machine" "sgs" {
  name     = "sgs-pipeline"
  role_arn = aws_iam_role.iam_stf.arn
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
  "StartAt": "Extract PGFN - ORIGIN",
  "States": {
    "Extract PGFN - ORIGIN": {
      "Type": "Map",
      "InputPath": "$",
      "ItemsPath": "$.origem",
      "ResultPath": "$.array",
      "MaxConcurrency": 3,
      "Next": "Transform PGFN - CHOOSE UF",
      "Parameters": {
        "origem.$": "$$.Map.Item.Value",
        "remessa.$": "$.remessa"
      },
      "Iterator": {
        "StartAt": "Extract PGFN",
        "States": {
          "Extract PGFN": {
            "End": true,
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "FunctionName": "${var.lambda_bucket_name[2]}:$LATEST",
              "Payload": {
                "origem.$": "$.origem",
                "remessa.$": "$.remessa"
              }
            }
          }
        }
      }
    },
    "Transform PGFN - CHOOSE UF": {
      "Type": "Map",
      "ItemsPath": "$.uf",
      "ResultPath": "$.array",
      "MaxConcurrency": 30,
      "Next": "Finished with sucess",
      "Parameters": {
        "uf.$": "$$.Map.Item.Value",
        "origem.$": "$.origem",
        "remessa.$": "$.remessa"
      },
      "Iterator": {
        "StartAt": "Transform PGFN - CHOOSE ORIGIN",
        "States": {
          "Transform PGFN - CHOOSE ORIGIN": {
            "End": true,
            "Type": "Map",
            "ItemsPath": "$.origem",
            "ResultPath": "$.array",
            "MaxConcurrency": 3000,
            "Parameters": {
              "origem.$": "$$.Map.Item.Value",
              "remessa.$": "$.remessa",
              "uf.$": "$.uf"
            },
            "Iterator": {
              "StartAt": "Transform PGFN",
              "States": {
                "Transform PGFN": {
                  "End": true,
                  "Type": "Task",
                  "Resource": "arn:aws:states:::lambda:invoke",
                  "Parameters": {
                    "FunctionName": "${var.lambda_bucket_name[3]}:$LATEST",
                    "Payload": {
                      "origem.$": "$.origem",
                      "remessa.$": "$.remessa",
                      "uf.$": "$.uf"
                    }
                  }
                }
              }
            }
          }
        }
      }
    },
    "Finished with sucess": {
      "Type": "Pass",
      "End": true
    }
  }
}
EOF

  depends_on = [aws_lambda_function.lambda, aws_s3_bucket.bucket,
    aws_iam_role_policy_attachment.stf_lambda_role_attach, aws_iam_role_policy_attachment.stf_xray_role_attach]
}

