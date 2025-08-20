terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

provider "aws" {
  alias   = "primary"
  region  = var.region
}

terraform {
  backend "s3" {
    bucket = "academy-tf"
    key    = "state/terraform.tfstate"
    region = "eu-west-1"
    use_lockfile = true
  }
}
