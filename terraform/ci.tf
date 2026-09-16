module "github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "~> 5.0"
}

module "github_deploy_role" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version  = "~> 5.0"
  name     = "${local.name}-github-deploy"
  subjects = [var.github_oidc_subject]
  policies = {
    ecr = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
    eks = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }
  depends_on = [module.github_oidc_provider]
}

# Lets the OIDC workflow upload only the frontend bucket and invalidate only
# this CloudFront distribution.
resource "aws_iam_role_policy" "github_frontend_deploy" {
  name = "${local.name}-github-frontend-deploy"
  role = module.github_deploy_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = module.frontend_s3.s3_bucket_arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${module.frontend_s3.s3_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = module.cloudfront.cloudfront_distribution_arn
      }
    ]
  })
}
