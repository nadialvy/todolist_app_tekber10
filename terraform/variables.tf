variable "project_id" {
  type        = string
  description = "GCP Project ID yang diambil dari GitHub Secret GCP_PROJECT_ID"
}

variable "region" {
  type    = string
  default = "asia-southeast2"
}