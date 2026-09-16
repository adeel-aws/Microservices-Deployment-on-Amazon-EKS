module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.use1
  }

  domain_name            = var.domain_name
  validation_method      = "DNS"
  create_route53_records = false
  wait_for_validation    = false
  tags                   = local.tags
}
