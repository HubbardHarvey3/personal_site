resource "aws_route53_zone" "hcubed" {
  name = "hcubedcoder.com"
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.hcubed.id
  name    = "hcubedcoder.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.hcubed.id
  name    = "www.hcubedcoder.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "hcubedcoder" {
  domain_name       = "hcubedcoder.com"
  validation_method = "DNS"

  tags = local.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.hcubedcoder.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.hcubed.zone_id
}

resource "aws_acm_certificate_validation" "hcubedcoder" {
  certificate_arn         = aws_acm_certificate.hcubedcoder.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
