terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.2"
    }
  }
}
