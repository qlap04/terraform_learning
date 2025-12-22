# S3 Backend Outputs
output "s3_bucket_name" {
  description = "Name of S3 bucket used for Terraform backend state"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_region
}


# DynamoDB Lock Table Outputs
output "dynamodb_table_name" {
  description = "DynamoDB table name used for state locking"
  value       = module.dynamodb-table.dynamodb_table_id
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = module.dynamodb-table.dynamodb_table_arn
}
