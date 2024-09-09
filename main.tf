terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.60.0"
    }
  }

  backend "s3" {
    bucket = "my-precious-state-bucket-hhh"
    key    = "hcubed_site"
    region = "us-east-1"
  }
}

locals {
  default_tags = {
    Lightsail = "Hcubed_Site"
  }
}

