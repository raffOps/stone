terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = "3.34.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


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

# ------ Push image ------------------------------
# Calculate hash of the Docker image source contents
# Calculate hash of the Docker image source contents
data "external" "hash" {
  program = [coalesce(var.hash_script, "${path.module}/hash_image.sh"), var.source_path]
}

# Build and push the Docker image whenever the hash changes
resource "null_resource" "push" {
  triggers = {
    hash = data.external.hash.result["hash"]
  }

  provisioner "local-exec" {
    command     = "${coalesce(var.push_script, "${path.module}/push_image.sh")} ${var.source_path} ${aws_ecr_repository.repo.repository_url} ${var.tag}"
    interpreter = ["bash", "-c"]
  }
}


# ---------- Output ---------------------------------------

output "repository_url" {
  description = "ECR repository URL of Docker image"
  value       = aws_ecr_repository.repo.repository_url
}

output "tag" {
  description = "Docker image tag"
  value       = var.tag
}

output "hash" {
  description = "Docker image source hash"
  value       = data.external.hash.result["hash"]
}
