# Configure the AWS Provider
provider "aws" {

  region = "us-east-2"
}

resource "aws_s3_bucket" "remote_state" {
    bucket = "dylan-tf-bucket"
    force_destroy = false
}

resource "aws_s3_bucket_versioning" "remote_state_versioning" {
  bucket = aws_s3_bucket.remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}