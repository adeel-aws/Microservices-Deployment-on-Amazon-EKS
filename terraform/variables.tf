variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "robot-shop"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "owner" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "admin_cidr_blocks" {
  description = "Public CIDR blocks allowed to access the EKS API."
  type        = list(string)
}

variable "domain_name" { type = string }
variable "frontend_bucket_name" { type = string }
variable "github_oidc_subject" { type = string }

variable "eks_version" {
  type    = string
  default = "1.31"
}

variable "node_instance_type" {
  type    = string
  default = "t3.small"
}

variable "node_min_size" {
  type    = number
  default = 3
}
variable "node_desired_size" {
  type    = number
  default = 3
}
variable "node_max_size" {
  type    = number
  default = 6
}
variable "rds_mysql_instance_class" {
  description = "RDS MySQL instance class. db.t3.micro is Free Tier-compatible."
  type        = string
  default     = "db.t3.micro"
}
variable "rds_mysql_backup_retention_period" {
  description = "RDS MySQL backup retention in days. Use 1 for Free Tier; use 7 or more in production."
  type        = number
  default     = 1
}
variable "redis_node_type" {
  type    = string
  default = "cache.t4g.small"
}
variable "mq_instance_type" {
  type    = string
  default = "mq.m7g.medium"
}
