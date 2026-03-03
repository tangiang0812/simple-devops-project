terraform {
  backend "s3" {
    bucket         = "standard-terraform-backend-s3-backend"
    dynamodb_table = "standard-terraform-backend-s3-backend"
    key            = "tfstate/tooling-prod/terraform.tfstate"
    region         = "us-west-1"
    assume_role = {
      role_arn = "arn:aws:iam::583857255987:role/Standard-Terraform-BackendS3BackendRole"
    }
  }
}
