# AIS Data Engineering Pipeline - Terraform Outputs
# This file defines the outputs from the Terraform configuration

output "bucket_name" {
  description = "The name of the GCS bucket created for AIS raw data"
  value       = google_storage_bucket.ais_raw_data.name
}

output "bucket_url" {
  description = "The URL of the GCS bucket"
  value       = "gs://${google_storage_bucket.ais_raw_data.name}"
}

output "bucket_self_link" {
  description = "The self link of the GCS bucket"
  value       = google_storage_bucket.ais_raw_data.self_link
}

output "staging_dataset_id" {
  description = "The ID of the BigQuery staging dataset"
  value       = google_bigquery_dataset.ais_staging.dataset_id
}

output "curated_dataset_id" {
  description = "The ID of the BigQuery curated dataset"
  value       = google_bigquery_dataset.ais_curated.dataset_id
}

output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region where resources are created"
  value       = var.region
}

output "bigquery_staging_reference" {
  description = "The reference to the BigQuery staging dataset (project.dataset)"
  value       = "${var.project_id}.${google_bigquery_dataset.ais_staging.dataset_id}"
}

output "bigquery_curated_reference" {
  description = "The reference to the BigQuery curated dataset (project.dataset)"
  value       = "${var.project_id}.${google_bigquery_dataset.ais_curated.dataset_id}"
}

# This output can be useful for automated scripts or CI/CD pipelines
output "resource_names" {
  description = "Map of all created resource names"
  value = {
    bucket             = google_storage_bucket.ais_raw_data.name
    staging_dataset    = google_bigquery_dataset.ais_staging.dataset_id
    curated_dataset    = google_bigquery_dataset.ais_curated.dataset_id
  }
}

# Information for connecting via Airflow and dbt
output "connection_strings" {
  description = "Information for connecting to created resources"
  value = {
    gcs_path          = "gs://${google_storage_bucket.ais_raw_data.name}"
    bigquery_staging  = "${var.project_id}:${google_bigquery_dataset.ais_staging.dataset_id}"
    bigquery_curated  = "${var.project_id}:${google_bigquery_dataset.ais_curated.dataset_id}"
  }
}
