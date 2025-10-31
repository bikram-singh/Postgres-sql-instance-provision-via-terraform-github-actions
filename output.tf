output "instance_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres_instance.connection_name
}

output "private_ip_address" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres_instance.ip_address[0].ip_address
}

output "database_version" {
  description = "The PostgreSQL version of the instance"
  value       = google_sql_database_instance.postgres_instance.database_version
}

output "ssl_mode" {
  description = "The SSL mode configuration"
  value       = "ENCRYPTED_ONLY"
}

output "deletion_protection_status" {
  description = "The deletion protection status"
  value       = google_sql_database_instance.postgres_instance.deletion_protection
}
