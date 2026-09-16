module "rds_mysql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.2.1"

  identifier           = "${local.name}-mysql"
  engine               = "mysql"
  family               = "mysql8.4"
  major_engine_version = "8.4"

  # db.t3.micro is Free Tier-compatible. RDS selects the currently supported
  # MySQL 8.0 patch version when no specific patch version is pinned.
  instance_class        = var.rds_mysql_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name                     = "robotshop"
  username                    = "robotshopadmin"
  manage_master_user_password = true

  port                    = 3306
  multi_az                = false
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = var.rds_mysql_backup_retention_period
  deletion_protection     = true
  skip_final_snapshot     = false

  create_db_subnet_group = false
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [module.sg_data.security_group_id]

  auto_minor_version_upgrade = true
  maintenance_window         = "sun:03:00-sun:04:00"
  backup_window              = "04:00-05:00"

  tags = local.tags
}

resource "random_password" "redis" {
  length  = 32
  special = false
}

module "redis" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "~> 1.0"

  replication_group_id       = "${local.name}-redis"
  description                = "Robot Shop Redis"
  engine_version             = "7.1"
  node_type                  = var.redis_node_type
  num_node_groups            = 1
  replicas_per_node_group    = 1
  automatic_failover_enabled = true
  multi_az_enabled           = true
  vpc_id                     = module.vpc.vpc_id
  create_security_group      = false
  security_group_ids         = [module.sg_data.security_group_id]
  subnet_ids                 = module.vpc.database_subnets
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  auth_token                 = random_password.redis.result
  tags                       = local.tags
}

resource "random_password" "rabbitmq" {
  length  = 24
  special = false
}

resource "aws_mq_broker" "rabbitmq" {
  broker_name                = "${local.name}-rabbitmq"
  engine_type                = "RabbitMQ"
  engine_version             = "3.13"
  auto_minor_version_upgrade = true
  host_instance_type         = var.mq_instance_type
  deployment_mode            = "SINGLE_INSTANCE"
  publicly_accessible        = false
  subnet_ids                 = [module.vpc.database_subnets[0]]
  security_groups            = [module.sg_data.security_group_id]
  user {
    username = "robotshop"
    password = random_password.rabbitmq.result
  }

  logs {
    general = true
  }
}

resource "aws_secretsmanager_secret" "mongodb_uri" {
  name = "${local.name}/mongodb-uri"
}
