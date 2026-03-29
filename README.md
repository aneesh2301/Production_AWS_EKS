# EKS Production Grade Project

This is a production-grade EKS cluster built with Terraform and Kubernetes best practices. Currently in active development.

---

## Progress

### ✅ Step 1 — Remote Backend

Configured a secure Terraform remote backend using:

- S3 bucket with versioning, AES-256 encryption, and public access blocked
- DynamoDB table for state locking
- `prevent_destroy` lifecycle to avoid accidental deletion

---

### ✅ Step 2 — Infrastructure (VPC + EKS)

Provisioned using official AWS Terraform modules, deployed in the `dev` environment.

**VPC** — creates the following across 2 Availability Zones:

- 2 Public Subnets
- 2 Private Subnets
- 1 NAT Gateway
- 1 Internet Gateway
- Public route table between Internet Gateway and Public Subnets
- Private route table between NAT Gateway and Private Subnets

**EKS** — Managed Node Groups with the following configuration:

- Nodes deployed in Private Subnets
- IRSA enabled (IAM Roles for Service Accounts — fine-grained least privilege)
- Cluster endpoint public access enabled (acceptable for dev, disabled in prod)
- OIDC provider created and URL exported as output
- Access entries used for IAM principal access (modern replacement for `aws-auth`)
- Control plane logging enabled for all components (api, audit, authenticator, controllerManager, scheduler)
- Core addons installed: CoreDNS, kube-proxy, vpc-cni

**Terraform Module Structure:**

```
terraform/
├── modules/
│   ├── vpc/          # Reusable VPC module
│   ├── eks/          # Reusable EKS module
│   ├── addons/       # Platform add-ons (Helm-based)
│   └── tags/         # Shared tagging conventions
├── envs/
│   ├── dev/          # Dev environment (thin composition layer)
│   ├── stage/        # Stage environment
│   └── prod/         # Production environment
└── remote-backend/   # S3 + DynamoDB bootstrap (run once)
```

---

### 🔄 Step 3 — Kubernetes Platform Components

Deploying cluster add-ons via Terraform Helm provider (in progress):

- AWS Load Balancer Controller
- External DNS
- cert-manager
- Cluster Autoscaler / Karpenter
- Metrics Server
- EBS CSI Driver

---

### ⏳ Step 4 — FastAPI Application

Deploying a Python FastAPI application with:

- Deployment, Service, HPA, PDB
- Ingress via ALB with TLS
- Network Policies (default deny)
- Resource requests and limits

---

### ⏳ Step 5 — CI/CD (GitHub Actions)

- Terraform plan on pull requests (OIDC auth to AWS — no static keys)
- Terraform apply gated on `main` branch
- App build, image scan, push to ECR
- Helm-based deploy with environment promotion

---

### ⏳ Step 6 — Observability

- **Metrics:** kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
- **Logs:** Loki + Fluent Bit
- SLO-based alerting (availability, p95 latency, error budget burn)

---

### ⏳ Step 7 — Security

- Pod Security Standards (restricted profile in prod namespaces)
- Kyverno policies (no privileged pods, no `latest` tag, required limits)
- External Secrets Operator with AWS Secrets Manager
- Network Policies enforced per namespace
- IRSA least-privilege IAM roles per workload