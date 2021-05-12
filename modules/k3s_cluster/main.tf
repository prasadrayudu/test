terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.34.0"
    }
  }
}

module "iam_policies" {
  source = "./iam_policies"
}

