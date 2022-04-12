terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0.0"
    }
    ec = {
      source  = "elastic/ec"
      version = "~> 0.4.0"
    }
  }
}
