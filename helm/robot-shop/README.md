# Robot Shop Helm chart

Update `values.yaml` with ECR registry and managed-service endpoints. Then run:

```powershell
helm upgrade --install robot-shop . -n robot-shop --create-namespace
```

The chart creates seven Deployments, six internal ClusterIP Services, one internal ALB Ingress, and HPAs. `dispatch` has no HTTP port, so it has no Service or HPA.
