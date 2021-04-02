
variable "image_name" {
  description = "Name of Docker image"
  type        = string
  default = "lambda_image"
}

variable "source_path" {
  description = "Path to Docker image source"
  type        = string
  default = "lambda_functions"
}

variable "tag" {
  description = "Tag to use for deployed Docker image"
  type        = string
  default     = "latest"
}

variable "hash_script" {
  description = "Path to script to generate hash of source contents"
  type        = string
  default     = "scripts/hash_image.sh"
}

variable "push_script" {
  description = "Path to script to build and push Docker image"
  type        = string
  default     = "scripts/push_image.sh"
}

variable "lambda_bucket_name" {
  type = set(string)
  default = ["sgs-extract", "sgs-transform", "pgfn-extract", "pgfn-transform"]
}
