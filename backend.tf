terraform {
  backend "s3" {
    bucket = "flasksqlgif-terraform-state"  # Your S3 bucket name
    key    = "terraform.tfstate"            # The path where the state file will be stored in the bucket
    region = "us-east-1"                    # AWS region where your S3 bucket is located
    encrypt = true                          # Encrypt the state file in S3
    acl     = "private"                     # Set access control list to private
  }
}
