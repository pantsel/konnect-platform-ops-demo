terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "3.3.0"
    }
  }
}

resource "minio_s3_bucket" "this" {
  bucket = "konnect.team.${var.team_name}"
}

resource "minio_iam_policy" "team_gh_policy" {
  name = "${var.team_name}-gh-oidc-policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": ["arn:aws:iam::${var.github_org}:repo/${var.repo_name}"]
        },
        "Action": [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": [
          "arn:aws:s3:::${minio_s3_bucket.this.bucket}",
          "arn:aws:s3:::${minio_s3_bucket.this.bucket}/*"
        ]
      }
    ]
  })
}

# ToDo: Remove this policy after tests
resource "minio_iam_policy" "platform_gh_policy" {
  name = "${var.team_name}-gh-oidc-policy-platform"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": ["arn:aws:iam::${var.github_org}:repo/konnect-platform-ops"]
        },
        "Action": [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": [
          "arn:aws:s3:::${minio_s3_bucket.this.bucket}",
          "arn:aws:s3:::${minio_s3_bucket.this.bucket}/*"
        ]
      }
    ]
  })
}