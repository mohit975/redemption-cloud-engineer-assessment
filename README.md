# Redemption Assessment

This repository follows the requested structure for the Accor EKS assessment and contains:

- Terraform infrastructure for a multi-AZ Amazon EKS platform
- Kubernetes manifests for the Redemption microservice
- A k6 load test that simulates steady traffic and 10x flash-sale spikes
- The architecture image used as the high-level reference

## Repository Layout

```text
redemption-assessment/
├── terraform/
├── kubernetes/
├── tests/
├── docs/
└── README.md
```

## Terraform Scope

The Terraform code provisions:

- VPC with public, private, and data subnets across three Availability Zones
- Amazon EKS with IRSA enabled and a baseline managed node group
- Amazon Aurora PostgreSQL with Multi-AZ resilience
- Amazon ElastiCache for Redis with Multi-AZ failover
- Amazon ECR for storing the workload image
- KMS, CloudTrail, GuardDuty, and a CloudWatch log group for security and auditability

## Kubernetes Scope

The Kubernetes manifests provide:

- Namespace isolation
- A test Deployment using `nginx:alpine` with health checks and spread constraints
- ClusterIP Service
- AWS ALB-backed Ingress
- HPA for pod autoscaling
- PDB for safer rollouts and node disruptions
- NetworkPolicy for default-deny style east-west control

## How To Use

1. Review and update variables in `terraform/variables.tf`.
2. Create a `terraform.tfvars` file inside `terraform/` with environment-specific values.
3. Configure AWS credentials before running Terraform.
4. Run Terraform from the `terraform/` directory.
5. Optionally set `aws_profile` in `terraform.tfvars`, or export `AWS_PROFILE`, if you use a named AWS CLI profile.
6. Apply the manifests from the `kubernetes/` directory after the cluster is ready.
7. Run the k6 test in `tests/load-test.js` against the deployed ingress endpoint.

## AWS Credentials

Terraform needs valid AWS credentials for both the S3 backend and the AWS provider.

- With AWS CLI default profile: run `aws configure`
- With a named profile: run `aws configure --profile accor`
- Then either set `aws_profile = "accor"` in `terraform.tfvars` or set `AWS_PROFILE=accor` before running Terraform
- If you use environment variables instead, set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION`

## Notes

- The ingress manifest contains placeholder values for host, certificate ARN, and security group IDs.
- The deployment currently uses `nginx:alpine` as a test image; switch it to the ECR URL output once you push your real application image.
- The default Terraform sizing is reduced for assessment and test use: EKS nodes default to `t3.small` and Redis defaults to `cache.t4g.micro`.
- Replace open CIDR ranges with Cloudflare IP ranges or your approved ingress ranges before production use.
- Karpenter, Prometheus, Grafana, and OpenTelemetry are represented in the design but would typically be installed after cluster creation using Helm or GitOps.

