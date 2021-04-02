resource "aws_ecr_repository" "repo" {
  name = var.image_name
}

resource "aws_ecr_lifecycle_policy" "repo-policy" {
  repository = aws_ecr_repository.repo.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep image deployed with tag '${var.tag}''",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["${var.tag}"],
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 2 any images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 2
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

}

data "aws_caller_identity" "this" {}
data "aws_region" "current" {}
data "aws_ecr_authorization_token" "token" {}

locals {
  ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
  ecr_image   = format("%v/%v:%v", local.ecr_address, aws_ecr_repository.repo.name, var.tag)
}

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "docker_registry_image" "app" {
  name = local.ecr_image

  build {
    context = "lambda_functions"
  }
}

# ------ Push image ------------------------------
# Calculate hash of the Docker image source contents
# Calculate hash of the Docker image source contents
//data "external" "hash" {
//  program = [coalesce(var.hash_script, "${path.module}/hash_image.sh"), var.source_path]
//}
//
//# Build and push the Docker image whenever the hash changes
//resource "null_resource" "push" {
//  triggers = {
//    hash = data.external.hash.result["hash"]
//  }
//
//  provisioner "local-exec" {
//    command     = "${coalesce(var.push_script, "${path.module}/push_image.sh")} ${var.source_path} ${aws_ecr_repository.repo.repository_url} ${var.tag}"
//    interpreter = ["bash", "-c"]
//  }
//}


# ---------- Output ---------------------------------------

output "repository_url" {
  description = "ECR repository URL of Docker image"
  value       = aws_ecr_repository.repo.repository_url
}

output "tag" {
  description = "Docker image tag"
  value       = var.tag
}

//output "hash" {
//  description = "Docker image source hash"
//  value       = data.external.hash.result["hash"]
//}
