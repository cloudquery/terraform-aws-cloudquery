terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.68"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.8.0"
    }
  }
}
