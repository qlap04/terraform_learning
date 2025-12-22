
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.9.0"

  bucket = "tf-state-dev-kai-se-stable-v1"

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  acl                      = null

  versioning = {
    enabled = true
  }
}

module "dynamodb-table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.4.0"

  name     = "backend-dev-lock"
  hash_key = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}