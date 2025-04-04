# AIS Data Engineering Pipeline - Terraform Variables
# This file defines the variables used in the Terraform configuration

variable "project_id" {
  description = "The Google Cloud Platform project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where resources will be created"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Prefix for the GCS bucket name (will be combined with project ID)"
  type        = string
  default     = "ais-data-lake"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "force_destroy_bucket" {
  description = "Whether to force destroy the bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "bucket_retention_days" {
  description = "Number of days to retain objects in the bucket before automatic deletion"
  type        = number
  default     = 365 # 1 year
}

variable "force_destroy_datasets" {
  description = "Whether to force destroy BigQuery datasets even if they contain tables"
  type        = bool
  default     = false
}

# Optional: Variables for BigQuery table schema
# Uncomment if you want to define schema through Terraform
/*
variable "ais_schema" {
  description = "Schema for BigQuery tables"
  type = list(object({
    name = string
    type = string
    mode = string
  }))
  default = [
    {
      name = "timestamp",
      type = "TIMESTAMP",
      mode = "REQUIRED"
    },
    {
      name = "mmsi",
      type = "STRING",
      mode = "REQUIRED"
    },
    {
      name = "latitude",
      type = "FLOAT64",
      mode = "REQUIRED"
    },
    {
      name = "longitude",
      type = "FLOAT64",
      mode = "REQUIRED"
    },
    {
      name = "type_of_mobile",
      type = "STRING",
      mode = "NULLABLE"
    },
    {
      name = "navigational_status",
      type = "STRING",
      mode = "NULLABLE"
    },
    {
      name = "rot",
      type = "FLOAT64",
      mode = "NULLABLE"
    },
    {
      name = "sog",
      type = "FLOAT64",
      mode = "NULLABLE"
    }
    # Add more fields as needed
  ]
}
*/
