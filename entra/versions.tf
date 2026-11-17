terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  cloud {
    organization = "felipe-iam-lab"

    workspaces {
      name = "novalab-entra"
    }
  }
}

provider "azuread" {}