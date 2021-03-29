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