variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "A unique name for the S3 bucket."
  type        = string
}