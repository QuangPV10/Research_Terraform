output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

# XÓA HOÀN TOÀN KHỐI OUTPUT "website_url" BÊN DƯỚI
# output "website_url" {
#  description = "The URL of the static website."
#  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
# }