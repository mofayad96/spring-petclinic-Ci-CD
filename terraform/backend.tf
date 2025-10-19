terraform {
  backend "s3" {
    bucket         = "petclinic-terraform-state-mofayad96"
    key            = "terraform/state.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}
