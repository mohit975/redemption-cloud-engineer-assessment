variable "aws_region" {
  description = "AWS region for the Redemption platform."
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "Optional AWS shared credentials profile name to use for local Terraform runs."
  type        = string
  default     = "terraform"
}

variable "project_name" {
  description = "Short application or platform name used for resource naming."
  type        = string
  default     = "redemption"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "prod"
}

variable "az_count" {
  description = "How many Availability Zones to use."
  type        = number
  default     = 3
}

variable "vpc_cidr" {
  description = "Primary CIDR block for the VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "eks_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.35"
}

variable "node_instance_types" {
  description = "Baseline instance types for the EKS managed node group. Cost-optimized for the test environment by default."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_min_size" {
  description = "Minimum node count for the baseline managed node group."
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired node count for the baseline managed node group."
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum node count for the baseline managed node group."
  type        = number
  default     = 9
}

variable "db_name" {
  description = "Aurora PostgreSQL database name."
  type        = string
  default     = "redemption"
}

variable "db_username" {
  description = "Aurora PostgreSQL master username."
  type        = string
  default     = "redemption_app"
}

variable "db_password" {
  description = "Aurora PostgreSQL master password."
  type        = string
  sensitive   = true
  default     = "RedemptionTest123!"

  validation {
    condition     = can(regex("^[^/@@\" ]+$", var.db_password))
    error_message = "db_password must not contain spaces, /, @, or \" characters because Aurora PostgreSQL rejects them."
  }
}

variable "aurora_instance_count" {
  description = "Number of Aurora instances."
  type        = number
  default     = 2
}

variable "redis_node_type" {
  description = "Instance class for the Redis replication group. Cost-optimized for the test environment by default."
  type        = string
  default     = "cache.t4g.micro"
}

variable "redis_num_cache_clusters" {
  description = "Number of Redis cache nodes spread across AZs."
  type        = number
  default     = 3
}

variable "cloudwatch_log_retention_days" {
  description = "Retention period for CloudWatch log groups."
  type        = number
  default     = 30
}

variable "ingress_cidrs" {
  description = "CIDR blocks allowed to reach the public ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "skip_final_snapshot" {
  description = "Skip the final Aurora snapshot during destroy for short-lived assessment environments."
  type        = bool
  default     = true
}
