
variable "image_name" {
  description = "Name of Docker image"
  type        = string
  default = "lambda_image"
}

variable "tag" {
  description = "Tag to use for deployed Docker image"
  type        = string
  default     = "latest"
}

variable "lambda_bucket_name" {
  type = set(string)
  default = ["sgs-extract", "sgs-transform", "pgfn-extract", "pgfn-transform"]
}
