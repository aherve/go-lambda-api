locals {
  project     = "go-lambda-api"
  environment = "production"
  region      = "eu-west-1"
}

terraform {
  backend s3 {
    bucket = "aherve-terraform"
    key    = "go-lambda-api/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider aws {
  alias   = "ire"
  region  = local.region
  version = "~> 2.30"
}

module main {
  source      = "../../"
  environment = local.environment

  providers = {
    aws = aws.ire
  }

}
