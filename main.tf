##-----------S3 CREATION AND CONFIGURATION-----------##

# create an empty s3 bucket
resource "aws_s3_bucket" "meister_lol_s3_bucket" {
  bucket = "tf-static-site.meister.lol"

  tags = {
    Name        = "tf-static-site.meister.lol"
    Environment = "Prod"
  }
}

# policy document for the s3 to allow getobject and listbucket from cloudfront

data "aws_iam_policy_document" "allow_readget_access_cloudfront_to_s3" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::tf-static-site.meister.lol/*",
      "arn:aws:s3:::tf-static-site.meister.lol",
    ]

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::671231939531:distribution/E33JRMUO5XD2GS"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

# policy attach

resource "aws_s3_bucket_policy" "allow_readget_access_cloudfront_to_s3" {
  bucket = aws_s3_bucket.meister_lol_s3_bucket.id
  policy = data.aws_iam_policy_document.allow_readget_access_cloudfront_to_s3.json
}

# add static website hosting settings to the bucket

resource "aws_s3_bucket_website_configuration" "meister_lol_s3_bucket_webconfig" {
  bucket = aws_s3_bucket.meister_lol_s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

##-----------S3 CREATION AND CONFIGURATION-----------##

