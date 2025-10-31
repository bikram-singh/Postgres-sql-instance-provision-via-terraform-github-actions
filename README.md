
# Postgres SQL Instance Provisioning (Terraform + GitHub Actions)

**What this repo does**  
Provision a Google Cloud **Cloud SQL (Postgres)** instance using Terraform and run CI/CD from **GitHub Actions**.  
It supports multi-environment layouts (dev/stage/prod), remote state in GCS, Workload Identity Federation (WIF) for GitHub Actions authentication, and lifecycle protection to avoid accidental instance deletion.

---

## 🏗️ Architecture Overview

- **GitHub Actions** executes Terraform automatically (init → validate → plan → apply).  
- Uses **Workload Identity Federation (OIDC)** — no JSON keys required.  
- **Terraform backend** stored in **Google Cloud Storage (GCS)**.  
- **Cloud SQL (Postgres)** instance is provisioned privately, with PITR + backup.  
- CI/CD pipeline supports environment parameterization (`dev`, `stage`, `prod`).

📊 Refer to `architecture_diagram.png` for the architecture visualization.

---

## 📂 Repository Structure

```
.
├── .github/workflows/terraform.yml        # GitHub Actions workflow file
├── environments/
│   ├── dev/
│   │   ├── backend.conf.tfvars            # Backend configuration for Dev
│   │   └── terraform.tfvars               # Variables specific to Dev
│   ├── stage/
│   │   ├── backend.conf.tfvars
│   │   └── terraform.tfvars
│   └── prod/
│       ├── backend.conf.tfvars
│       └── terraform.tfvars
├── main.tf                                # Cloud SQL Instance, DB & User
├── providers.tf                           # GCP Provider setup
├── terraform.tf                           # Terraform settings
├── variables.tf                           # Input variables
├── output.tf                              # Output values
├── .gitignore                             # Ignored files
└── README.md                              # This file
```

---

## ⚙️ Prerequisites

### 1️⃣ Local Setup (optional)
- Terraform >= 1.0 (1.8.5 recommended)
- gcloud SDK (optional for local tests)

### 2️⃣ GCP Setup
Enable these APIs:
- Cloud SQL Admin API
- IAM API
- Service Networking API
- Compute Engine API

Create:
- VPC network (`postgre-vpc` as example)
- GCS bucket per environment for Terraform backend

### 3️⃣ GitHub Setup
Set repository secrets:
- `GCP_WIF_PROVIDER`
- `GCP_SA_EMAIL`
- `TF_VAR_db_password`

Ensure WIF setup is completed (see below).

---

## 🚀 Quick Start (Local)

```bash
terraform init -backend-config="bucket=dev-us-central1-terraform-state" -backend-config="prefix=terraform/state/dev"
terraform plan -var-file=environments/dev/terraform.tfvars -out=tfplan
terraform apply -auto-approve tfplan
```

---

## 🤖 GitHub Actions Workflow

**Triggers:**
- On commit to `environments/*/**`
- Manual via `workflow_dispatch`

**Secrets used:**
```bash
GCP_WIF_PROVIDER = projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-action-postgres-pool/providers/github
GCP_SA_EMAIL     = postgres-sql@PROJECT_ID.iam.gserviceaccount.com
TF_VAR_db_password = <your_db_password>
```

**Workflow steps:**
1. Checkout repository  
2. Detect environment (`dev`, `stage`, `prod`)  
3. Authenticate via `google-github-actions/auth@v2`  
4. Initialize Terraform backend  
5. Run `terraform fmt`, `validate`, `plan`, and (manual) `apply`  

---

## 🌍 Environment Configuration Files

### ✅ backend.conf.tfvars (example)

Each environment folder must contain this file:

```hcl
bucket = "dev-us-central1-terraform-state"
prefix = "terraform/state/dev"
```

For stage or prod, modify accordingly:
```hcl
bucket = "stage-us-central1-terraform-state"
prefix = "terraform/state/stage"
```
```hcl
bucket = "prod-us-central1-terraform-state"
prefix = "terraform/state/prod"
```

---

### ✅ terraform.tfvars (example)

```hcl
project_id               = "gke-11111"
instance_name            = "postgres-instance-dev-tfs"
region                   = "us-central1"
db_version               = "POSTGRES_18"
tier                     = "db-custom-1-3840"
storage_type             = "PD_SSD"
storage_size             = 15
vpc_network              = "postgre-vpc"
db_user                  = "admin"
database_name            = "test_db"
backup_location          = "us"
log_retention_days       = 7
retained_backups         = 7
deletion_protection      = false
retain_backups_on_delete = true
final_backup_on_delete   = true

user_labels = {
  environment = "dev"
  team        = "data"
  project     = "rate-auto"
}
```

---

## 🔐 Lifecycle Protection & Safe Updates

Terraform will **not delete** your instance accidentally and **ignore safe updates** (like disk size changes).

Example lifecycle block (already added in `main.tf`):

```hcl
lifecycle {
  prevent_destroy = true
  ignore_changes = [
    settings[0].availability_type,
    settings[0].tier,
    settings[0].disk_type,
    settings[0].disk_size,
    settings[0].activation_policy,
    settings[0].backup_configuration,
    settings[0].user_labels,
    settings[0].database_flags,
    settings[0].maintenance_window
  ]
}
```

---

## 🧭 Workload Identity Federation (WIF) Setup

1. Create a WIF pool and provider in IAM → Workload Identity Federation.  
2. Use issuer URL: `https://token.actions.githubusercontent.com`  
3. Bind your service account to the provider:

```bash
gcloud iam service-accounts add-iam-policy-binding postgres-sql@PROJECT_ID.iam.gserviceaccount.com   --role="roles/iam.workloadIdentityUser"   --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-action-postgres-pool/*"
```

4. Save provider ID and SA email in GitHub Secrets.

---

## 🧰 Troubleshooting

| Error | Description | Fix |
|-------|--------------|-----|
| `Failed to read file backend.conf` | File missing or wrong path | Ensure filename is `backend.conf.tfvars` |
| `403 storage.objects.list denied` | Missing IAM permissions | Add `roles/storage.objectAdmin` |
| `Unsupported attribute in ignore_changes` | Provider mismatch | Remove unsupported keys |
| `Failed to delete instance` | Deletion protection true | Set to false or adjust lifecycle |
| `Code 3` | Formatting error | Run `terraform fmt -recursive` |

---

## 🔒 Security Tips

- Never commit secrets or service account JSON files  
- Use only Workload Identity Federation (no static keys)  
- Store DB password in GitHub secrets  
- Use GCS versioning & audit logs for Terraform state  
- Apply least-privilege roles for CI/CD service account

---

## 🤝 Contributing

1. Fork the repo  
2. Create your feature branch  
3. Commit changes  
4. Submit a PR 🚀

---

_Last updated: October 2025_  
Maintainer: **Bikram Singh**
