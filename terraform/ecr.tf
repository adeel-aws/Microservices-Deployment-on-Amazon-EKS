module "ecr_catalogue" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "~> 2.0"
  repository_name                 = "rs-catalogue"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true
  repository_lifecycle_policy     = local.ecr_lifecycle_policy
  tags                            = local.tags
}

module "ecr_user" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "~> 2.0"
  repository_name                 = "rs-user"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true
  repository_lifecycle_policy     = local.ecr_lifecycle_policy
  tags                            = local.tags
}

module "ecr_cart" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "~> 2.0"
  repository_name                 = "rs-cart"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true
  repository_lifecycle_policy     = local.ecr_lifecycle_policy
  tags                            = local.tags
}

module "ecr_shipping" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "~> 2.0"
  repository_name                 = "rs-shipping"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true
  repository_lifecycle_policy     = local.ecr_lifecycle_policy
  tags                            = local.tags
}

module "ecr_ratings" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "~> 2.0"
  repository_name                 = "rs-ratings"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true
  repository_lifecycle_policy     = local.ecr_lifecycle_policy
  tags                            = local.tags
}

module "ecr_payment" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "~> 2.0"
  repository_name                 = "rs-payment"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true
  repository_lifecycle_policy     = local.ecr_lifecycle_policy
  tags                            = local.tags
}

module "ecr_dispatch" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "~> 2.0"
  repository_name                 = "rs-dispatch"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true
  repository_lifecycle_policy     = local.ecr_lifecycle_policy
  tags                            = local.tags
}

module "ecr_mongo" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "~> 2.0"
  repository_name                 = "rs-mongo"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true
  repository_lifecycle_policy     = local.ecr_lifecycle_policy
  tags                            = local.tags
}
