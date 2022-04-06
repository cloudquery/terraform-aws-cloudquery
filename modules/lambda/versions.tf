terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.68"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.8.0"
    }
  }
}
