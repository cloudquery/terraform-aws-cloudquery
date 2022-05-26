terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
  }
}