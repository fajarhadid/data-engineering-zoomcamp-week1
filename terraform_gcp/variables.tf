variable "location" {
  description = "My location"
  default = "asia-southeast1"
}

variable "bq_dataset_name"{
    description = "Bigquery Dataset name"
    default = "terraform_bigquery"
}

variable "gcs_storage_class" {
  description = "GCS storage class name"
  default = ""

}

variable "gcs_bucket_name" {
  description = "GCS storage bucket name"
  default = "terraform-demo-448406-terraform-bucket"
}