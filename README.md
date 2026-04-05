Terraform
│
▼
AWS Infrastructure
├ VPC
├ EKS
├ ECR
└ IAM
│
▼
Developer
│
▼
GitLab
│
▼
GitLab CI
│
├ Test
├ Build Image
├ Trivy Scan
└ Push → ECR
│
▼
GitOps Repo
│
▼
ArgoCD
│
▼
EKS
├ Ingress
├ Prometheus
├ Grafana
└ Application
