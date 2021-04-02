terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = "3.34.0"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "2.11.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
