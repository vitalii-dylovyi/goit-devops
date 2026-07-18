terraform {
  backend "s3" {
    bucket         = "vitalii-tf-state-lesson-8-9"
    key            = "lesson-8-9/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
