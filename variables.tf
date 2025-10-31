variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for the Cloud SQL instance"
  type        = string
  default     = "us-central1"
}

variable "instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
}

variable "db_version" {
  description = "The version of PostgreSQL to use"
  type        = string
  default     = "POSTGRES_13"
}

variable "tier" {
  description = "The machine type for the Cloud SQL instance"
  type        = string
}

variable "storage_type" {
  description = "The type of storage to use (SSD or HDD)"
  type        = string
  default     = "SSD"
}

variable "storage_size" {
  description = "The size of the storage in GB"
  type        = number
  default     = 10
}

variable "vpc_network" {
  description = "The VPC network name for private IP"
  type        = string
}

variable "db_user" {
  description = "The database user name"
  type        = string
}

variable "db_password" {
  description = "Database password (provided securely via TF_VAR_db_password)"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "The name of the database to create"
  type        = string
}

variable "backup_location" {
  description = "The location for storing backups"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
}

variable "retained_backups" {
  description = "Number of automated backups to retain"
  type        = number
}

variable "deletion_protection" {
  description = "Enable deletion protection for the instance"
  type        = bool
  default     = true
}

variable "retain_backups_on_delete" {
  description = "Retain backups after instance deletion"
  type        = bool
  default     = true
}

variable "final_backup_on_delete" {
  description = "Create final backup on instance deletion"
  type        = bool
  default     = true
}
