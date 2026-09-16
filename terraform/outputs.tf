output "eks_cluster_name" { value = module.eks.cluster_name }
output "cloudfront_domain" { value = module.cloudfront.cloudfront_distribution_domain_name }
output "frontend_bucket" { value = module.frontend_s3.s3_bucket_id }
output "acm_validation_records" { value = module.acm.acm_certificate_domain_validation_options }
output "rds_mysql_endpoint" { value = module.rds_mysql.db_instance_address }
output "redis_endpoint" { value = module.redis.replication_group_primary_endpoint_address }
output "github_role_arn" { value = module.github_deploy_role.arn }
