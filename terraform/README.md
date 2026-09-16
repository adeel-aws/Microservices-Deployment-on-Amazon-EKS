# Robot Shop AWS infrastructure

This directory provisions the AWS platform for Robot Shop in **us-east-1**. Terraform creates the network, EKS platform, data services, image registries, CloudFront delivery layer, and GitHub OIDC deployment role. The application itself is deployed separately by the [Helm chart](../helm/robot-shop/README.md).

## What `terraform apply` creates

| Area | Services |
| --- | --- |
| Networking | `10.40.0.0/16` VPC, three AZs, public/private/database subnets, Internet Gateway, one NAT Gateway, S3 Gateway VPC endpoint, security groups |
| Kubernetes | EKS 1.31, private managed node group, VPC CNI, CoreDNS, kube-proxy, EBS CSI, Metrics Server, Cluster Autoscaler, AWS Load Balancer Controller |
| Data | RDS MySQL, TLS/authenticated ElastiCache Redis, Amazon MQ RabbitMQ |
| Delivery | ECR repositories, private S3 frontend bucket, CloudFront with OAC and VPC origin, WAF, ACM certificate, GitHub Actions OIDC role |

## Network design

The VPC uses three AZs. Public subnets host NAT/internet-facing network components; private subnets host EKS nodes and the internal ALB; database subnets contain RDS, Redis, and RabbitMQ. Private workload traffic uses the single NAT Gateway only when it needs public AWS/internet access. S3 traffic uses the Gateway endpoint.

## IAM and EKS

EKS IRSA is enabled. The EBS CSI controller receives `AmazonEBSCSIDriverPolicy` through its own service account role rather than broad worker-node permissions. The AWS Load Balancer Controller is installed through the existing EKS Blueprints Add-ons module and uses the cluster OIDC provider. GitHub Actions assumes a Terraform-managed OIDC role and receives cluster access through an EKS access entry.

## Before you apply

1. Install Terraform and AWS CLI, then authenticate to the intended AWS account.
2. Complete any AWS account verification required for CloudFront.
3. Copy the example file and set the required values:

   ```powershell
   Copy-Item terraform.tfvars.example terraform.tfvars
   ```

   Provide the owner tag, DNS domain, frontend bucket name, GitHub OIDC subject, and the CIDRs permitted to access the EKS API. Never commit `terraform.tfvars`.
4. Ensure the operator has permissions for VPC, EC2, IAM, EKS, ECR, RDS, ElastiCache, Amazon MQ, S3, CloudFront, WAF, ACM, and Route 53-independent certificate validation.

## Commands

```powershell
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

To remove a disposable environment, review the destructive plan carefully, then run:

```powershell
terraform destroy
```

## Security and cost notes

- S3 is private; CloudFront has access through Origin Access Control only.
- CloudFront uses ACM TLS and WAF. `/api/*` uses a VPC origin to reach the internal ALB.
- RDS is encrypted and uses a Free Tier-compatible `db.t3.micro` setting here. Backup retention defaults to one day for this account; raise it for a production account that supports the chosen retention period.
- Redis requires TLS/authentication and RabbitMQ uses secure AMQPS. Data security-group ingress is limited to EKS nodes.
- NAT Gateway, managed data services, EKS worker nodes, and CloudFront can incur charges. Review the Terraform plan before every apply.

## File guide

| File | Purpose |
| --- | --- |
| `network.tf` | VPC, subnets, NAT, S3 endpoint, data security group |
| `eks.tf` | EKS, add-ons, managed nodes, IRSA and controller configuration |
| `data-services.tf` | RDS MySQL, Redis, RabbitMQ and credentials integration |
| `ecr.tf` | Service ECR repositories |
| `frontend.tf` | S3, CloudFront, OAC, WAF, VPC origin |
| `acm.tf` | Certificate and validation records output |
| `ci.tf` | GitHub OIDC deployment role |
| `outputs.tf` | Values needed by Helm and GitHub Actions |

After apply, continue with the [application delivery guide](../app/README.md).
