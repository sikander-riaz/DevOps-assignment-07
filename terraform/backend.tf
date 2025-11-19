terraform {
  backend "s3" {
    bucket         = "s3-tf-state-dev-2026"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-dev"
    encrypt        = true
  }
}
