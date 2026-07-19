terraform {
  backend "s3" {
    bucket         = "vitalii-tf-state-final-project"
    key            = "final-project/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
