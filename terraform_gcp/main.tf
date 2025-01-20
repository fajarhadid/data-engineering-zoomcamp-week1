terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "terraform-demo-448406"
  region  = "asia-southeast1"
}

resource "google_storage_bucket" "auto-expire" {
  name     = var.gcs_bucket_name
  location = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "bigquery-dataset" {
  dataset_id = var.bq_dataset_name
  location = var.location
}
