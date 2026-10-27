terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = ">= 4.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  cloud {
    organization = "felipe-iam-lab"

    workspaces {
      name = "novalab-okta"
    }
  }
}

provider "okta" {}