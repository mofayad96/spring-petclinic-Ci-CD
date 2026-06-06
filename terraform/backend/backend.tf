terraform {
  backend "s3" {
    bucket         = "petclinic-terraform-state-bucket-12345"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "petclinic-tf-locks"
    encrypt        = true
  }
}
