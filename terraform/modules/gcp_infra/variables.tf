variable "project_id" {
  type        = string
  description = "GCP Project ID dari project focusbuddy-cicd"
}

variable "region" {
  type        = string
  default     = "asia-southeast2"
}

variable "bucket_names" {
  type        = list(string)
  default     = ["dev", "preview", "prod"]
  description = "Kumpulan nama environment untuk bucket GCS"
}