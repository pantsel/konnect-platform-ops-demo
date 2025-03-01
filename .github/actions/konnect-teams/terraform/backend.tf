terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://${var.minio_server}"
    }
  }
}