variable "team_name" {
  description = "The name of the team"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "github_org" {
  description = "The GitHub organization to create teams and repositories in"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}