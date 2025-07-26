provider "aws" {
  region = var.aws_region
}

# 1. S3 bucket giờ sẽ là private
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
  tags = {
    Name    = "My Static Website Bucket"
    Project = "Terraform GitHub Actions Demo"
  }
}

# KHÔNG cần resource "aws_s3_bucket_website_configuration" nữa vì bucket là private.
# KHÔNG cần resource "aws_s3_bucket_public_access_block" vì mặc định đã block là điều ta muốn.

# 2. Tạo Origin Access Control để cho phép CloudFront truy cập S3
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "OAC for ${var.bucket_name}"
  description                       = "Origin Access Control Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 3. Sửa lại Bucket Policy để chỉ cho phép CloudFront
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontOAC"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            # Chỉ cho phép truy cập từ CloudFront distribution này
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

# 4. Cấu hình CloudFront để sử dụng OAC
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "S3-${var.bucket_name}"
    # Thêm dòng này để kết nối với OAC
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    # Giữ nguyên các cấu hình khác
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}