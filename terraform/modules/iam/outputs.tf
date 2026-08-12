output "kms_key_arn" {
  value = aws_kms_key.platform.arn
}

output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail.bucket
}

output "application_log_group_name" {
  value = aws_cloudwatch_log_group.application.name
}
