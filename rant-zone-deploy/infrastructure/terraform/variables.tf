# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# VPC Configuration
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "rant-zone-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "Public subnet configurations"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    {
      name = "rant-zone-public-1a"
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    },
    {
      name = "rant-zone-public-1b"
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  ]
}

variable "private_subnets" {
  description = "Private subnet configurations"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    {
      name = "rant-zone-private-1a"
      cidr = "10.0.10.0/24"
      az   = "us-east-1a"
    },
    {
      name = "rant-zone-private-1b"
      cidr = "10.0.11.0/24"
      az   = "us-east-1b"
    }
  ]
}

# RDS Configuration
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "rantzone"
}

variable "database_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "database_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

# ElastiCache Configuration
variable "redis_cluster_name" {
  description = "Redis cluster name"
  type        = string
  default     = "rant-zone-redis"
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

# ECR Configuration
variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "rant-zone-backend"
}

variable "ecr_image_tag" {
  description = "ECR image tag"
  type        = string
  default     = "latest"
}

# ECS Configuration
variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "rant-zone-cluster"
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
  default     = "rant-zone-backend"
}

variable "ecs_cpu" {
  description = "ECS task CPU units"
  type        = string
  default     = "256"
}

variable "ecs_memory" {
  description = "ECS task memory (MiB)"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "ECS service desired count"
  type        = number
  default     = 2
}

variable "ecs_min_count" {
  description = "ECS service minimum count"
  type        = number
  default     = 1
}

variable "ecs_max_count" {
  description = "ECS service maximum count"
  type        = number
  default     = 10
}

# ALB Configuration
variable "alb_name" {
  description = "Application Load Balancer name"
  type        = string
  default     = "rant-zone-alb"
}

variable "target_group_name" {
  description = "Target group name"
  type        = string
  default     = "rant-zone-backend-tg"
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "S3 bucket name for frontend"
  type        = string
  default     = "rant-zone-frontend"
}

variable "s3_cors_configuration" {
  description = "S3 CORS configuration"
  type = object({
    allowed_origins = list(string)
    allowed_methods = list(string)
    allowed_headers = list(string)
    max_age_seconds = number
  })
  default = {
    allowed_origins = ["https://rant.zone", "https://www.rant.zone"]
    allowed_methods = ["GET", "HEAD"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

# CloudFront Configuration
variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "rant.zone"
}

variable "cloudfront_aliases" {
  description = "CloudFront aliases"
  type        = list(string)
  default     = ["rant.zone", "www.rant.zone"]
}

variable "subject_alternative_names" {
  description = "SSL certificate subject alternative names"
  type        = list(string)
  default     = ["*.rant.zone", "www.rant.zone", "api.rant.zone"]
}

# Route53 Configuration
variable "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

# WAF Configuration
variable "waf_name" {
  description = "WAF name"
  type        = string
  default     = "rant-zone-waf"
}

variable "waf_rate_limit_rule" {
  description = "WAF rate limit rule"
  type = object({
    rate_limit = number
    time_window = number
  })
  default = {
    rate_limit = 2000
    time_window = 300
  }
}

variable "waf_blocked_ips" {
  description = "WAF blocked IPs"
  type        = list(string)
  default     = []
}

# CloudWatch Configuration
variable "cloudwatch_log_groups" {
  description = "CloudWatch log groups"
  type = list(object({
    name = string
    retention_days = number
  }))
  default = [
    {
      name = "/aws/ecs/rant-zone-backend"
      retention_days = 30
    },
    {
      name = "/aws/rds/rant-zone-db"
      retention_days = 30
    }
  ]
}

variable "cloudwatch_alarms" {
  description = "CloudWatch alarms"
  type = object({
    cpu_utilization = object({
      threshold = number
      evaluation_periods = number
      period = number
    })
    memory_utilization = object({
      threshold = number
      evaluation_periods = number
      period = number
    })
    database_connections = object({
      threshold = number
      evaluation_periods = number
      period = number
    })
  })
  default = {
    cpu_utilization = {
      threshold = 80
      evaluation_periods = 2
      period = 300
    }
    memory_utilization = {
      threshold = 80
      evaluation_periods = 2
      period = 300
    }
    database_connections = {
      threshold = 80
      evaluation_periods = 2
      period = 300
    }
  }
}

# CI/CD Configuration
variable "codebuild_project_name" {
  description = "CodeBuild project name"
  type        = string
  default     = "rant-zone-build"
}

variable "codepipeline_name" {
  description = "CodePipeline name"
  type        = string
  default     = "rant-zone-pipeline"
}

# Environment Variables
variable "environment_variables" {
  description = "Environment variables for ECS tasks"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "PORT"
      value = "3001"
    },
    {
      name  = "HOST"
      value = "0.0.0.0"
    },
    {
      name  = "LOG_LEVEL"
      value = "info"
    },
    {
      name  = "ALLOWED_ORIGINS"
      value = "https://rant.zone,https://www.rant.zone"
    },
    {
      name  = "RATE_LIMIT_MAX"
      value = "100"
    },
    {
      name  = "RATE_LIMIT_WINDOW_MS"
      value = "900000"
    },
    {
      name  = "WS_HEARTBEAT_INTERVAL"
      value = "30000"
    },
    {
      name  = "WS_CONNECTION_TIMEOUT"
      value = "60000"
    },
    {
      name  = "MODERATION_ENABLED"
      value = "true"
    },
    {
      name  = "MAX_MESSAGE_LENGTH"
      value = "500"
    },
    {
      name  = "MAX_MESSAGES_PER_MINUTE"
      value = "10"
    },
    {
      name  = "MESSAGE_CLEANUP_INTERVAL"
      value = "3600000"
    },
    {
      name  = "MESSAGE_EXPIRY_DAYS"
      value = "30"
    }
  ]
} 