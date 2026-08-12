locals {
  name         = "${var.project_name}-${var.environment}"
  cluster_name = "${local.name}-eks"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Service     = "The Redemption"
  }
}

module "iam" {
  source = "./modules/iam"

  name                          = local.name
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days
  tags                          = local.tags
}

module "vpc" {
  source = "./modules/vpc"

  name          = local.name
  cluster_name  = local.cluster_name
  az_count      = var.az_count
  vpc_cidr      = var.vpc_cidr
  ingress_cidrs = var.ingress_cidrs
  tags          = local.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name                  = local.cluster_name
  cluster_version               = var.eks_version
  vpc_id                        = module.vpc.vpc_id
  private_subnet_ids            = module.vpc.private_subnet_ids
  node_instance_types           = var.node_instance_types
  node_min_size                 = var.node_min_size
  node_desired_size             = var.node_desired_size
  node_max_size                 = var.node_max_size
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days
  kms_key_arn                   = module.iam.kms_key_arn
  tags                          = local.tags
}

resource "aws_security_group_rule" "aurora_from_eks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.vpc.aurora_security_group_id
  source_security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "redis_from_eks" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.vpc.redis_security_group_id
  source_security_group_id = module.eks.node_security_group_id
}

module "aurora" {
  source = "./modules/aurora"

  name                = local.name
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  instance_count      = var.aurora_instance_count
  subnet_ids          = module.vpc.data_subnet_ids
  security_group_id   = module.vpc.aurora_security_group_id
  kms_key_arn         = module.iam.kms_key_arn
  skip_final_snapshot = var.skip_final_snapshot
  tags                = local.tags
}

module "redis" {
  source = "./modules/redis"

  name               = local.name
  subnet_ids         = module.vpc.data_subnet_ids
  security_group_id  = module.vpc.redis_security_group_id
  kms_key_arn        = module.iam.kms_key_arn
  redis_node_type    = var.redis_node_type
  num_cache_clusters = var.redis_num_cache_clusters
  tags               = local.tags
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

resource "aws_iam_role" "alb_controller" {
  name = "${local.name}-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "alb_controller" {
  name = "${local.name}-alb-controller"
  role = aws_iam_role.alb_controller.id
  policy = file("${path.module}/modules/iam/aws-load-balancer-controller-policy.json")
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"
  wait       = true

  values = [yamlencode({
    clusterName = module.eks.cluster_name
    region      = var.aws_region
    vpcId       = module.vpc.vpc_id
    serviceAccount = {
      create = true
      name   = "aws-load-balancer-controller"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
      }
    }
  })]

  depends_on = [module.eks, aws_iam_role_policy.alb_controller]
}

resource "aws_ecr_repository" "redemption" {
  name                 = local.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_ecr_lifecycle_policy" "redemption" {
  repository = aws_ecr_repository.redemption.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images beyond 10"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
