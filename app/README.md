# Robot Shop application delivery

This directory contains the Robot Shop source code, service Dockerfiles, database seed assets, static frontend files, and the GitHub Actions workflow used to release the application to the AWS platform created by [`../terraform`](../terraform/README.md).

## Services

| Service | Description | Runtime dependency |
| --- | --- | --- |
| `catalogue` | Product catalogue API | MongoDB |
| `user` | User API | MongoDB, Redis |
| `cart` | Shopping cart API | Redis |
| `shipping` | Shipping API | RDS MySQL (`cities`) |
| `ratings` | Ratings API | RDS MySQL (`ratings`) |
| `payment` | Publishes payment work | Amazon MQ RabbitMQ over AMQPS |
| `dispatch` | Consumes payment work | Amazon MQ RabbitMQ over AMQPS |
| `mongo` | MongoDB image and seed data | EBS-backed StatefulSet |
| `web/static` | Storefront static files | S3 and CloudFront |

## Deployment model

```text
terraform/  → AWS infrastructure
helm/       → Kubernetes workloads, services, ingress and autoscaling
app/        → source code, containers and CI/CD workflow
```

The Helm chart is at [`../helm/robot-shop`](../helm/robot-shop/README.md). It deploys ClusterIP services, an internal ALB ingress, HPA resources, and a MongoDB StatefulSet with a persistent EBS claim.

## Runtime configuration and secrets

The release expects the Kubernetes runtime secret `robot-shop-runtime`. It contains connection values for MongoDB, TLS-enabled ElastiCache Redis, AMQPS RabbitMQ, and RDS MySQL. Credentials are never committed to Helm values, Dockerfiles, workflows, or source code.

Database initialization assets are retained in `mysql/scripts/`:

- `10-dump.sql.gz` initializes Shipping’s `cities` database.
- `20-ratings.sql` initializes Ratings’ `ratings` database.

## GitHub Actions CI/CD

The workflow is [`.github/workflows/build-and-deploy.yml`](.github/workflows/build-and-deploy.yml). On every push to `main`, it compares changed files and builds only the affected service images. Each image is pushed to its matching ECR repository as `rs-<service>:<git-sha>`. The Helm release receives only the changed image tag, so unrelated workloads are not restarted.

```text
catalogue change → catalogue build → rs-catalogue ECR → Helm updates catalogue only
web/static change → S3 sync → CloudFront invalidation
```

Before enabling EKS deployment, configure these GitHub repository settings:

| Type | Name | Value/source |
| --- | --- | --- |
| Secret | `AWS_GITHUB_ACTIONS_ROLE_ARN` | Terraform output `github_role_arn` |
| Variable | `ROBOT_SHOP_DEPLOY_ENABLED` | `true` |
| Variable | `FRONTEND_S3_BUCKET` | Terraform output `frontend_bucket` |
| Variable | `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront distribution ID from Terraform/AWS |

The deployment job runs on a private runner labelled `self-hosted`, `linux`, and `robot-shop-eks`, because the EKS API is private to the platform network. The workflow uses GitHub OIDC and must not receive static AWS access keys.

## Useful commands

From the repository root after AWS authentication and Kubernetes access are configured:

```powershell
aws eks update-kubeconfig --region us-east-1 --name robot-shop-prod
helm upgrade --install robot-shop ./helm/robot-shop --namespace robot-shop --create-namespace --wait
kubectl get pods,svc,ingress -n robot-shop
```

For a local source build, each service has its own Dockerfile. Do not place production credentials in local `.env` files that will be committed.
