terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "dev-us-central-1-terraform-state"
    prefix = "terraform/state/dev"
  }
}
