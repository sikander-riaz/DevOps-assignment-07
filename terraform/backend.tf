terraform {
  backend "s3" {
    bucket         = "s3-tf-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-dev"
    encrypt        = true
  }
}
