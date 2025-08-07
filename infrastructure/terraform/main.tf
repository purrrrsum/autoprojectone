terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "rant-zone-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "rant-zone"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"
  
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
}

# Security Groups
module "security_groups" {
  source = "./modules/security_groups"
  
  vpc_id = module.vpc.vpc_id
  
  depends_on = [module.vpc]
}

# RDS Database
module "rds" {
  source = "./modules/rds"
  
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_ids  = [module.security_groups.rds_security_group_id]
  
  instance_class      = var.rds_instance_class
  database_name       = var.database_name
  master_username     = var.database_username
  master_password     = var.database_password
  
  depends_on = [module.vpc, module.security_groups]
}

# ElastiCache Redis
module "elasticache" {
  source = "./modules/elasticache"
  
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.redis_security_group_id]
  
  cluster_name = var.redis_cluster_name
  node_type    = var.redis_node_type
  
  depends_on = [module.vpc, module.security_groups]
}

# ECR Repository
module "ecr" {
  source = "./modules/ecr"
  
  repository_name = var.ecr_repository_name
  image_tag       = var.ecr_image_tag
}

# ECS Cluster and Service
module "ecs" {
  source = "./modules/ecs"
  
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.ecs_security_group_id]
  
  cluster_name = var.ecs_cluster_name
  service_name = var.ecs_service_name
  
  ecr_repository_url = module.ecr.repository_url
  ecr_image_tag      = var.ecr_image_tag
  
  cpu    = var.ecs_cpu
  memory = var.ecs_memory
  
  desired_count = var.ecs_desired_count
  min_count     = var.ecs_min_count
  max_count     = var.ecs_max_count
  
  environment_variables = var.environment_variables
  
  depends_on = [module.vpc, module.security_groups, module.ecr]
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"
  
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.alb_security_group_id]
  
  alb_name = var.alb_name
  
  target_group_name = var.target_group_name
  health_check_path = var.health_check_path
  
  depends_on = [module.vpc, module.security_groups]
}

# S3 Bucket for Frontend
module "s3" {
  source = "./modules/s3"
  
  bucket_name = var.s3_bucket_name
  domain_name = var.domain_name
  
  cors_configuration = var.s3_cors_configuration
}

# CloudFront Distribution
module "cloudfront" {
  source = "./modules/cloudfront"
  
  s3_bucket_domain_name = module.s3.bucket_domain_name
  s3_bucket_id          = module.s3.bucket_id
  
  domain_name = var.domain_name
  aliases     = var.cloudfront_aliases
  
  ssl_certificate_arn = module.acm.certificate_arn
  
  depends_on = [module.s3, module.acm]
}

# ACM Certificate
module "acm" {
  source = "./modules/acm"
  
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
}

# Route53 DNS
module "route53" {
  source = "./modules/route53"
  
  hosted_zone_id = var.hosted_zone_id
  domain_name    = var.domain_name
  
  cloudfront_distribution_domain_name = module.cloudfront.distribution_domain_name
  alb_dns_name                        = module.alb.alb_dns_name
  
  depends_on = [module.cloudfront, module.alb]
}

# WAF
module "waf" {
  source = "./modules/waf"
  
  waf_name = var.waf_name
  
  rate_limit_rule = var.waf_rate_limit_rule
  blocked_ips     = var.waf_blocked_ips
}

# CloudWatch Logs
module "cloudwatch" {
  source = "./modules/cloudwatch"
  
  log_groups = var.cloudwatch_log_groups
  alarms     = var.cloudwatch_alarms
}

# CodeBuild and CodePipeline
module "ci_cd" {
  source = "./modules/ci_cd"
  
  project_name = var.codebuild_project_name
  pipeline_name = var.codepipeline_name
  
  ecr_repository_url = module.ecr.repository_url
  ecs_cluster_name   = module.ecs.cluster_name
  ecs_service_name   = module.ecs.service_name
  
  depends_on = [module.ecr, module.ecs]
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.endpoint
}

output "redis_endpoint" {
  description = "Redis endpoint"
  value       = module.elasticache.endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
} 