terraform {
  backend "gcs" {
    bucket = "focusbuddy-tfstate-global"
    prefix = "terraform/state"
  }
}