provider "google" {
  project = var.project_id
  region  = var.region
}

# Memanggil modul gcp_infra yang sudah kamu buat sebelumnya
module "gcp_infra" {
  source     = "./modules/gcp_infra"
  project_id = var.project_id
  region     = var.region
}