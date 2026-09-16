module "frontend_s3" {
  source                  = "terraform-aws-modules/s3-bucket/aws"
  version                 = "~> 5.0"
  bucket                  = var.frontend_bucket_name
  versioning              = { enabled = true }
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  tags                    = local.tags
}

resource "aws_wafv2_web_acl" "frontend" {
  provider = aws.use1
  name     = "${local.name}-waf"
  scope    = "CLOUDFRONT"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "robotshop"
    sampled_requests_enabled   = true
  }
}

data "aws_lb" "robot_shop_api" {
  name = "robot-shop-api"
}

module "cloudfront" {
  source              = "terraform-aws-modules/cloudfront/aws"
  version             = "~> 5.0"
  aliases             = [var.domain_name]
  default_root_object = "index.html"
  create_origin_access_control = true
  origin_access_control = {
    s3 = {
      description      = "Robot Shop frontend"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    s3 = {
      domain_name           = module.frontend_s3.s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3"
    }
    api = {
      domain_name = data.aws_lb.robot_shop_api.dns_name
      vpc_origin_config = {
        vpc_origin = "robot_shop_api"
      }
    }
  }

  create_vpc_origin = true
  vpc_origin = {
    robot_shop_api = {
      name                   = "${local.name}-api-origin"
      arn                    = data.aws_lb.robot_shop_api.arn
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = {
        items    = ["TLSv1.2"]
        quantity = 1
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/api/*"
      target_origin_id       = "api"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      query_string           = true
      headers                = ["Authorization", "Content-Type", "Origin"]
      cookies_forward        = "all"
      min_ttl                = 0
      default_ttl            = 0
      max_ttl                = 0
    }
  ]

  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  web_acl_id = aws_wafv2_web_acl.frontend.arn
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = module.frontend_s3.s3_bucket_id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "cloudfront.amazonaws.com" }, Action = "s3:GetObject", Resource = "${module.frontend_s3.s3_bucket_arn}/*", Condition = { StringEquals = { "AWS:SourceArn" = module.cloudfront.cloudfront_distribution_arn } } }] })
}
