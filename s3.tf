resource "aws_s3_bucket" "hcubedcoder" {
  bucket = "hcubedcoder.com"
  tags   = local.default_tags
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.hcubedcoder.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["${aws_cloudfront_distribution.s3_distribution.arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "oac_readonly" {
  bucket = aws_s3_bucket.hcubedcoder.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
