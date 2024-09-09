locals {
  s3_origin_id = "hcubedOrigin"
}

resource "aws_cloudfront_origin_access_control" "hcubedcoder" {
  name                              = "hcubedcoder_oac"
  description                       = "OAC for Hcubedcoder"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.hcubedcoder.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.hcubedcoder.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["hcubedcoder.com"]

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "MX"]
    }
  }

  tags = local.default_tags

  viewer_certificate {
    minimum_protocol_version = "TLSv1.2_2021"
    acm_certificate_arn = aws_acm_certificate.hcubedcoder.arn
    ssl_support_method = "sni-only"
  }
}
