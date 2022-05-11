terraform {

    backend "s3" {
    bucket = "dylan-tf-bucket"
    key    = "tf_key.json"
    region = "us-east-2"
  }
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.11.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {

  region = "us-east-2"
}

#This was created in setup/setup.tf - now getting an error when using these resources 

# resource "aws_s3_bucket" "remote_state" {
#     bucket = "dylan-tf-bucket"
#     force_destroy = false
# }

# resource "aws_s3_bucket_versioning" "remote_state_versioning" {
#   bucket = aws_s3_bucket.remote_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }