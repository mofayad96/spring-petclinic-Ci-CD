# terraform {
#   backend "s3" {
#     bucket         = "petclinic-terraform-state-bucket-12345"
#     key            = "dev/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "petclinic-tf-locks"
#     encrypt        = true
#   }
# }