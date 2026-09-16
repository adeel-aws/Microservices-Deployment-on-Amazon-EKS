module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = var.vpc_cidr
  azs  = var.azs

  public_subnets   = ["10.40.0.0/20", "10.40.16.0/20", "10.40.32.0/20"]
  private_subnets  = ["10.40.64.0/20", "10.40.80.0/20", "10.40.96.0/20"]
  database_subnets = ["10.40.128.0/20", "10.40.144.0/20", "10.40.160.0/20"]

  enable_nat_gateway           = true
  one_nat_gateway_per_az       = false
  single_nat_gateway           = true
  enable_dns_hostnames         = true
  enable_dns_support           = true
  create_database_subnet_group = true
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.tags
}

# Gateway endpoints are free and keep S3 traffic inside AWS networking.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
}

module "sg_data" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${local.name}-data"
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    { rule = "mysql-tcp", source_security_group_id = module.eks.node_security_group_id },
    { rule = "redis-tcp", source_security_group_id = module.eks.node_security_group_id },
    { from_port = 5671, to_port = 5671, protocol = "tcp", description = "Secure AMQP from EKS", source_security_group_id = module.eks.node_security_group_id },
  ]

  egress_rules = ["all-all"]
  tags         = local.tags
}
