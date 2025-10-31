# Below values below are placeholders. Update them as per your environment (Dev, Stage, or Prod).

project_id               = "gke-11111"                   # Change project name as per environment Dev, Prod
instance_name            = "postgres-instance-stage-tfs"   # Change instance name as per environment Dev, Prod
region                   = "us-central1"
db_version               = "POSTGRES_18"
tier                     = "db-custom-1-3840"
storage_type             = "PD_SSD"
storage_size             = 10
vpc_network              = "postgre-vpc"                 # Change vpc name as per environment Dev, Prod
db_user                  = "admin"
database_name            = "test_db"
backup_location          = "us"
log_retention_days       = 7
retained_backups         = 7
deletion_protection      = true
retain_backups_on_delete = true
final_backup_on_delete   = true
