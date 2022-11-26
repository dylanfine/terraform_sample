resource "aws_s3_bucket" "input_bucket" {
    bucket = "test-input-bucket-1000"
    acl = "private"
    force_destroy = true
  
}

resource "aws_s3_bucket_public_access_block" "input_bucket_access_block" {
    bucket = aws_s3_bucket.input_bucket.id
    block_public_acls = true
    ignore_public_acls = true
    block_public_policy = true
    restrict_public_buckets = true
  
}


resource "aws_s3_bucket" "output_bucket" {
    bucket = "test-output-bucket-1000"
    acl = "private"
    force_destroy = true
  
}

resource "aws_s3_bucket_public_access_block" "output_bucket_access_block" {
    bucket = aws_s3_bucket.output_bucket.id
    block_public_acls = true
    ignore_public_acls = true
    block_public_policy = true
    restrict_public_buckets = true
  
}

