output "bucket_urls" {
  value = { for k, v in google_storage_bucket.flutter_web_buckets : k => v.url }
}

output "bucket_names" {
  value = { for k, v in google_storage_bucket.flutter_web_buckets : k => v.name }
}