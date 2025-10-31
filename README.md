# Google Cloud SQL PostgreSQL Instance with Terraform

This Terraform project provisions a secure, production-ready PostgreSQL instance on Google Cloud Platform (GCP) with comprehensive backup, monitoring, and security configurations.

## 🏗 Architecture Overview

This infrastructure creates:
- **Cloud SQL PostgreSQL 18 instance** with regional high availability
- **Private IP configuration** with VPC network integration
- **Automated backup system** with point-in-time recovery
- **Database user and schema** setup
- **Enhanced logging and monitoring** configuration
- **Remote state management** using GCS bucket

## 📋 Prerequisites

Before running this Terraform configuration, ensure you have:

- [Terraform](https://www.terraform.io/downloads.html) ≥ 1.0 installed  
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated  
- GCP project with the following APIs enabled:
  - Cloud SQL Admin API  
  - Compute Engine API  
  - Service Networking API  
- Appropriate IAM permissions:
  - Cloud SQL Admin  
  - Compute Network Admin  
  - Storage Admin (for GCS backend)  
- Existing VPC network (referenced in `vpc_network` variable)  
- GCS bucket for Terraform state storage  

## 🚀 Quick Start

### 1. Clone and Configure

```bash
cd rate-auto-tf-gcp-postgres-sql-instance
```

Copy and customize the variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Update Configuration

Edit `terraform.tfvars` with your specific values:

```hcl
project_id     = "your-gcp-project-id"
instance_name  = "your-postgres-instance-name"
region         = "us-central1"
vpc_network    = "your-vpc-network-name"
db_user        = "your-db-username"
db_password    = "your-secure-password"
database_name  = "your-database-name"
# ... other variables
```

### 3. Initialize and Deploy

```bash
terraform init
terraform plan
terraform apply
```

## 📂 Project Structure

```
main.tf           # Core Cloud SQL resources
variables.tf      # Variable definitions
terraform.tfvars  # Variable values (customize this)
output.tf         # Output definitions
providers.tf      # Provider configurations
terraform.tf      # Terraform and backend configuration
README.md         # This file
```

## ⚙️ Configuration Details

### Cloud SQL Instance Features

- **Database Version**: PostgreSQL 18  
- **High Availability**: Regional configuration with automatic failover  
- **Storage**: SSD with auto-resize enabled  
- **Network**: Private IP only (no public access)  
- **SSL/TLS**: Encrypted connections only  
- **Backup**: Automated daily backups with 7-day retention  
- **Point-in-time Recovery**: Enabled with 7-day transaction log retention  

### Security Features

- Private IP configuration (no public internet access)
- VPC network integration
- SSL/TLS encryption enforced
- Database flags for enhanced logging
- Deletion protection enabled
- Comprehensive audit logging

### Monitoring & Logging

- Connection/disconnection logging  
- Checkpoint logging  
- Lock wait logging  
- Query performance insights  

## 🧩 Variables Reference

| Variable | Description | Type | Default | Required |
|-----------|-------------|------|----------|-----------|
| `project_id` | GCP project ID | string | - | ✅ |
| `instance_name` | Cloud SQL instance name | string | - | ✅ |
| `region` | GCP region | string | `us-central1` | ✅ |
| `db_version` | PostgreSQL version | string | `POSTGRES_18` | ❌ |
| `tier` | Machine type | string | - | ✅ |
| `storage_type` | Storage type (SSD/HDD) | string | `SSD` | ❌ |
| `storage_size` | Storage size in GB | number | `10` | ❌ |
| `vpc_network` | VPC network name | string | - | ✅ |
| `db_user` | Database username | string | - | ✅ |
| `db_password` | Database password | string | - | ✅ |
| `database_name` | Database name | string | - | ✅ |
| `backup_location` | Backup storage location | string | - | ✅ |
| `log_retention_days` | Log retention period | number | - | ✅ |
| `retained_backups` | Number of backups to retain | number | - | ✅ |
| `deletion_protection` | Enable deletion protection | bool | `true` | ❌ |

## 🧾 Outputs

After successful deployment, the following information will be available:

- `instance_connection_name`: Connection string for the instance  
- `private_ip_address`: Private IP address  
- `database_version`: PostgreSQL version  
- `ssl_mode`: SSL configuration status  

## ☁️ State Management

This project uses **Google Cloud Storage (GCS)** for remote state management:

**Bucket**: `dev-us-central1-terraform-state`  
**Prefix**: `terraform/state/dev`  

### Benefits:
- Team collaboration  
- State locking  
- Versioning and backup  

### State structure supports multiple environments:

```
terraform/state/dev/      # Development
terraform/state/staging/  # Staging
terraform/state/prod/     # Production
```

## 🔧 Operations

### Connecting to the Database

```bash
# Using Cloud SQL Proxy
cloud_sql_proxy --instances=PROJECT_ID:REGION:INSTANCE_NAME=tcp:5432

# Direct connection (within VPC)
psql -h PRIVATE_IP -U USERNAME -d DATABASE_NAME
```

### Backup Management

```bash
# List backups
gcloud sql backups list --instance=INSTANCE_NAME

# Create manual backup
gcloud sql backups create --instance=INSTANCE_NAME
```

### Monitoring

Access through:
- Google Cloud Console → SQL → Monitoring  
- Cloud Monitoring dashboards  
- Query insights for performance analysis  

### ⚠ Important Notes

#### Security Considerations
- Database password is stored in plain text in `terraform.tfvars`  
- Password is visible in Terraform state file  
- No encryption at rest for sensitive variables  

### Organizational Constraints
Due to organizational policies, this project currently cannot implement:
- Google Secret Manager integration  
- Service account key rotation  
- Advanced IAM policies  

## 🔐 Security Recommendations & Future Improvements

### Immediate Improvements

1. **Password Management**
   ```hcl
   export TF_VAR_db_password="your-secure-password"
   ```
   Or use Terraform Cloud variables with `sensitive` flag enabled.

2. **State File Security**
   - Enable GCS bucket encryption  
   - Implement bucket-level IAM policies  
   - Enable audit logging for bucket access  

3. **Network Security**
   - Implement VPC firewall rules  
   - Use Private Google Access  
   - Consider VPC peering for cross-project access  

### Long-term Enhancements

1. **Secret Management (Future)**  
   ```hcl
   resource "google_secret_manager_secret" "db_password" {
     secret_id = "postgres-admin-password"
   }
   ```

2. **Infrastructure Improvements**
   - Multi-environment support (dev/staging/prod)
   - Add replicas for read scaling
   - Implement certificate rotation
   - Custom monitoring and alerting

3. **CI/CD Integration**
   - Terraform Cloud/Enterprise integration
   - Terratest automation
   - GitOps workflow (Sentinel/OPA)

4. **Disaster Recovery**
   - Cross-region backup replication
   - Automated recovery procedures
   - RTO/RPO documentation

5. **Compliance & Governance**
   - Resource tagging and cost management
   - Security Command Center compliance checks

## 🤝 Contributing

### Areas for Contribution
1. **Security Enhancements**
   - Secret management integration
   - Advanced IAM configurations

2. **Feature Additions**
   - Multi-environment support
   - Monitoring and alerting

3. **Documentation**
   - Operational runbooks
   - Troubleshooting guides
   - Architecture diagrams

4. **Testing**
   - Terratest integration
   - Performance benchmarking

### How to Contribute
1. Fork the repository  
2. Create a feature branch (`git checkout -b feature/amazing-feature`)  
3. Commit changes (`git commit -m 'Add amazing feature'`)  
4. Push branch (`git push origin feature/amazing-feature`)  
5. Open a Pull Request  

### Contribution Guidelines
- Follow Terraform best practices  
- Include comprehensive documentation  
- Add variable validation  
- Test in dev environment  
- Update README with new features  

## 📞 Support

For questions or issues:
1. Check documentation  
2. Search repository issues  
3. Create a new issue  
4. Contact the infrastructure team  

## 📄 License
This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

## 🏷 Tags
`terraform` `gcp` `postgresql` `cloud-sql` `iac` `devops` `database` `security`

---
**Last Updated**: October 2025  
**Terraform Version**: ≥ 1.0  
**Google Provider Version**: ~> 5.0  
