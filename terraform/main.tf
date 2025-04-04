# AIS Data Engineering Pipeline - Terraform Configuration
# Main infrastructure configuration for GCP resources

# Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "storage_api" {
  project = var.project_id
  service = "storage.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "bigquery_api" {
  project = var.project_id
  service = "bigquery.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

# GCS Bucket for Raw Data
resource "google_storage_bucket" "ais_raw_data" {
  name     = "${var.bucket_name}-${var.project_id}"
  location = var.region
  
  # Wait for the API to be enabled
  depends_on = [google_project_service.storage_api]

  # Optional configurations
  force_destroy               = var.force_destroy_bucket
  uniform_bucket_level_access = true
  
  # Lifecycle rules for data retention
  lifecycle_rule {
    condition {
      age = var.bucket_retention_days
    }
    action {
      type = "Delete"
    }
  }

  # Labels for resource organization
  labels = {
    environment = var.environment
    project     = "ais-pipeline"
    managed_by  = "terraform"
  }
}

# BigQuery Dataset for Staging Data
resource "google_bigquery_dataset" "ais_staging" {
  dataset_id    = "ais_staging"
  friendly_name = "AIS Data Staging"
  description   = "Staging dataset for raw AIS data"
  location      = var.region
  
  # Wait for the API to be enabled
  depends_on = [google_project_service.bigquery_api]

  # Optional configurations
  delete_contents_on_destroy = var.force_destroy_datasets
  
  # Access control
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  # Labels for resource organization
  labels = {
    environment = var.environment
    project     = "ais-pipeline"
    managed_by  = "terraform"
    data_tier   = "staging"
  }
}

# BigQuery Dataset for Curated Data
resource "google_bigquery_dataset" "ais_curated" {
  dataset_id    = "ais_curated"
  friendly_name = "AIS Data Curated"
  description   = "Curated dataset for transformed AIS data"
  location      = var.region
  
  # Wait for the API to be enabled
  depends_on = [google_project_service.bigquery_api]

  # Optional configurations
  delete_contents_on_destroy = var.force_destroy_datasets
  
  # Access control
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  # Labels for resource organization
  labels = {
    environment = var.environment
    project     = "ais-pipeline"
    managed_by  = "terraform"
    data_tier   = "curated"
  }
}

# Optional: BigQuery External Table for Raw Data
# Uncomment if you want to create an external table directly
/*
resource "google_bigquery_table" "ais_external_table" {
  dataset_id = google_bigquery_dataset.ais_staging.dataset_id
  table_id   = "ais_external"
  
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    
    source_uris = [
      "gs://${google_storage_bucket.ais_raw_data.name}/*.csv",
    ]
    
    # CSV options
    csv_options {
      quote             = "\""
      skip_leading_rows = 1
    }
  }
  
  depends_on = [
    google_bigquery_dataset.ais_staging,
    google_storage_bucket.ais_raw_data
  ]
}
*/
