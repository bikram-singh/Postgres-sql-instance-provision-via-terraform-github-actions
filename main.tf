resource "google_sql_database_instance" "postgres_instance" {
  name                = var.instance_name
  region              = var.region
  database_version    = var.db_version
  project             = var.project_id
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = "REGIONAL"
    disk_type         = var.storage_type
    disk_size         = var.storage_size
    disk_autoresize   = true
    activation_policy = "ALWAYS"

    user_labels = {
      environment = "dev"
      team        = "data"
      project     = "rate-auto"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/${var.vpc_network}"
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "00:00"
      location                       = var.backup_location
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = var.log_retention_days

      backup_retention_settings {
        retained_backups = var.retained_backups
        retention_unit   = "COUNT"
      }
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    maintenance_window {
      day  = 1
      hour = 0
    }
  }
}

resource "google_sql_user" "postgres_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
  project  = var.project_id
}

resource "google_sql_database" "postgres_db" {
  name     = var.database_name
  instance = google_sql_database_instance.postgres_instance.name
  project  = var.project_id
}
