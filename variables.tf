variable "s3_bucket_name" {
  type = map(string)
  default = {
    sgs_estagio_1 = "rjr-sgs-estagio-1"
    sgs_estagio_2 = "rjr-sgs-estagio-2"
    pgfn_estagio_1 = "rjr-pgfn-estagio-1"
    pgfn_estagio_2 = "rjr-pfgn-estagio-2"
  }
}

variable "image_name" {
  description = "Name of Docker image"
  type        = string
  default = "lambda_image"
}

variable "source_path" {
  description = "Path to Docker image source"
  type        = string
  default = "."
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

variable "lambda_name" {
  type = map(string)
  default = {
    sgs_extract    = "sgs-extract"
    sgs_transform  = "sgs-transform"
    pgfn_extract   = "pgfn-extract"
    pgfn_transform = "pgfn-transform"
  }
}

