# terraform {
#   backend "s3" {
#     bucket         = "standard-terraform-s3-backend"
#     dynamodb_table = "standard-terraform-s3-backend"
#     key            = "tfstate/tooling-prod/terraform.tfstate"
#     encrypt        = true // terraform will manage permissions for encryption
#     region         = "us-east-1"
#     assume_role = {
#       role_arn = "arn:aws:iam::583857255987:role/Standard-TerraformS3BackendRole"
#     }
#   }
# }
