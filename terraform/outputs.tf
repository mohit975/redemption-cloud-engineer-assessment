output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by EKS worker nodes."
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs intended for internet-facing load balancers."
  value       = module.vpc.public_subnet_ids
}

output "ingress_security_group_id" {
  description = "Security group for the public ALB created by the AWS Load Balancer Controller."
  value       = module.vpc.ingress_security_group_id
}

output "aurora_endpoint" {
  description = "Writer endpoint for the Aurora cluster."
  value       = module.aurora.endpoint
}

output "aurora_secret_arn" {
  description = "Secrets Manager ARN containing the Aurora connection details."
  value       = module.aurora.secret_arn
}

output "redis_primary_endpoint" {
  description = "Primary endpoint for the Redis replication group."
  value       = module.redis.primary_endpoint_address
}

output "cloudtrail_bucket_name" {
  description = "S3 bucket storing CloudTrail logs."
  value       = module.iam.cloudtrail_bucket_name
}

output "ecr_repository_name" {
  description = "ECR repository name for the Redemption workload image."
  value       = aws_ecr_repository.redemption.name
}

output "ecr_repository_url" {
  description = "ECR repository URL for the Redemption workload image."
  value       = aws_ecr_repository.redemption.repository_url
}

output "configure_kubeconfig" {
  description = "Command to merge the cluster into your local kubeconfig."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
