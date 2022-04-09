terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5"
    }
  }
}