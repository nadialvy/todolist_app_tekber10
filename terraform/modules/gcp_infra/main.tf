resource "google_storage_bucket" "flutter_web_buckets" {
  for_each      = toset(variable.bucket_names)
  name          = "focusbuddy-${each.key}-${variable.project_id}"
  location      = variable.region
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_binding" "public_rule" {
  for_each = google_storage_bucket.flutter_web_buckets
  bucket   = each.value.name
  role     = "roles/storage.objectViewer"
  members  = ["allUsers"]
}