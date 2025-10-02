# required provider(aws) , version of terraform
terraform {
required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 6.0"
    }
}
backend "s3" {
    bucket         = "petclinic-terraform-state-mofayad96"
    key            = "terraform/state.tfstate"
    region         = "eu-central-1"
    encrypt        = true
}
required_version = ">= 1.2"
}
