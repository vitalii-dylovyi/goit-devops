terraform {
  backend "s3" {
    bucket         = "vitalii-tf-state-lesson-db-module"
    key            = "lesson-db-module/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
