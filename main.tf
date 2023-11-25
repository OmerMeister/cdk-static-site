####---- s3 buckets ----####

# bucket for the website files
resource "aws_s3_bucket" "dp1000_webcontent" {
  bucket = var.project_domain_name #bucket name

  tags = {
    Project = "dp1000"
  }
}

# bucket for the codepipeline artifact files
resource "aws_s3_bucket" "dp1000_codepipelineartifact" {
  bucket = "codepipelineartifact.${var.project_domain_name}" #bucket name

  tags = {
    Project = "dp1000"
  }
}


# policy document for the tf_static_site bucket to allow getobject and listbucket from cloudfront
# it enables cloudfront to serve webpages fromt the bucket and also to serve custom error pages

data "aws_iam_policy_document" "dp1000_allow_readget_access_cloudfront_to_s3" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::${var.project_domain_name}/*",
      "arn:aws:s3:::${var.project_domain_name}",
    ]

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.dp1000_cf_distribution.arn] # our cloudfront resource arn
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }

}

# attaching the policy document to the tf_static_site bucket

resource "aws_s3_bucket_policy" "dp1000_allow_readget_access_cloudfront_to_s3" {
  bucket = aws_s3_bucket.dp1000_webcontent.id
  policy = data.aws_iam_policy_document.dp1000_allow_readget_access_cloudfront_to_s3.json

}

# add static website hosting settings to the tf_static_site bucket

resource "aws_s3_bucket_website_configuration" "dp1000_webcontent" {
  bucket = aws_s3_bucket.dp1000_webcontent.id

  index_document {
    suffix = "index.html"
  }
}


####---- roles and policies ----####

####---- rold and policy 1 ----####

resource "aws_iam_policy" "dp1000_pipeline_policy" {
  name        = "dp1000_pipeline_policy"
  description = "Policy used in trust relationship with CodePipeline github to s3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "iam:PassRole",
        ],
        Resource = "*",
        Effect   = "Allow",
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "cloudformation.amazonaws.com",
              "elasticbeanstalk.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com",
            ],
          },
        },
      },
      {
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      {
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      {
        Action = [
          "codestar-connections:UseConnection",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      {
        Action = [
          "elasticbeanstalk:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "cloudformation:*",
          "rds:*",
          "sqs:*",
          "ecs:*",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:ListFunctions",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      {
        Action = [
          "opsworks:CreateDeployment",
          "opsworks:DescribeApps",
          "opsworks:DescribeCommands",
          "opsworks:DescribeDeployments",
          "opsworks:DescribeInstances",
          "opsworks:DescribeStacks",
          "opsworks:UpdateApp",
          "opsworks:UpdateStack",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      {
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:UpdateStack",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      {
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      {
        Effect = "Allow",
        Action = [
          "devicefarm:ListProjects",
          "devicefarm:ListDevicePools",
          "devicefarm:GetRun",
          "devicefarm:GetUpload",
          "devicefarm:CreateUpload",
          "devicefarm:ScheduleRun",
        ],
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = [
          "servicecatalog:ListProvisioningArtifacts",
          "servicecatalog:CreateProvisioningArtifact",
          "servicecatalog:DescribeProvisioningArtifact",
          "servicecatalog:DeleteProvisioningArtifact",
          "servicecatalog:UpdateProduct",
        ],
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = [
          "cloudformation:ValidateTemplate",
        ],
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:DescribeImages",
        ],
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = [
          "states:DescribeExecution",
          "states:DescribeStateMachine",
          "states:StartExecution",
        ],
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = [
          "appconfig:StartDeployment",
          "appconfig:StopDeployment",
          "appconfig:GetDeployment",
        ],
        Resource = "*",
      },
    ],
  })
  tags = {
    Project = "dp1000"
  }
}

resource "aws_iam_role" "dp1000_pipeline_role" {
  name = "dp1000_pipeline_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
  tags = {
    Project = "dp1000"
  }
}

resource "aws_iam_policy_attachment" "dp1000_pipeline_attachment" {
  name       = "dp1000_pipeline_attachment"
  policy_arn = aws_iam_policy.dp1000_pipeline_policy.arn
  roles      = [aws_iam_role.dp1000_pipeline_role.name]

}


####---- rold and policy 2 ----####

resource "aws_iam_policy" "dp1000_lambda1_policy" {
  name        = "dp1000_lambda1_policy"
  description = "Policy for Lambda function to interact with CodePipeline, CloudFront, and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codepipeline:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations"
        ],
        Resource = "${aws_cloudfront_distribution.dp1000_cf_distribution.arn}"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "dp1000_lambda1_role" {
  name = "dp1000_lambda1_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Project = "dp1000"
  }
}

resource "aws_iam_policy_attachment" "dp1000_lambda1_attachment" {
  name       = "example-attachment"
  policy_arn = aws_iam_policy.dp1000_lambda1_policy.arn
  roles      = [aws_iam_role.dp1000_lambda1_role.name]
}

####---- GitHub codestar connections ----####

resource "aws_codestarconnections_connection" "OmerMeister_GitHub" {
  name          = "OmerMeister_GitHub"
  provider_type = "GitHub"
  tags = {
    Project = "dp1000"
  }
}
# then, go to https://eu-north-1.console.aws.amazon.com/codesuite/settings/connections?region=us-east-1 to one time manually approve the connection


####---- lambda1 function ----####

resource "aws_lambda_function" "dp1000_lambda1" {
  function_name = "dp1000_lambda1"
  handler       = "dp1000_lambda1.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.dp1000_lambda1_role.arn
  timeout       = 6
  memory_size   = 128
  filename      = data.archive_file.dp1000_python_code.output_path
  lifecycle {
    ignore_changes = [filename]
  }
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      DISTRIBUTION = aws_cloudfront_distribution.dp1000_cf_distribution.id
    }
  }
  tags = {
    Project = "dp1000"
  }
}

# specify lambda source file location. leave zip location as is
data "archive_file" "dp1000_python_code" {
  type        = "zip"
  output_path = "${path.module}/dp1000_lambda1.zip"
  source {
    content  = file("${path.module}/auxiliary/dp1000_lambda1.py")
    filename = "dp1000_lambda1.py"
  }
}

####---- cloudfront origin access control ----####

resource "aws_cloudfront_origin_access_control" "dp1000_oac" {
  name                              = "${var.project_domain_name}.s3.us-east-1.amazonaws.com"
  description                       = "OAC_sign_request"
  signing_protocol                  = "sigv4"
  signing_behavior                  = "always"
  origin_access_control_origin_type = "s3"
}

####---- cloudfront distribution ----####

resource "aws_cloudfront_distribution" "dp1000_cf_distribution" {
  origin {
    domain_name              = "${var.project_domain_name}.s3.us-east-1.amazonaws.com"
    origin_id                = "${var.project_domain_name}.s3-website.us-east-1.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.dp1000_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  aliases = ["${var.project_domain_name}"]

  default_cache_behavior {
    target_origin_id       = "${var.project_domain_name}.s3-website.us-east-1.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]

    cached_methods = ["HEAD", "GET"]

    compress = true

    min_ttl          = 0
    default_ttl      = 86400
    max_ttl          = 31536000
    smooth_streaming = false

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

  custom_error_response {
    error_code            = 404
    response_page_path    = "/error.html"
    response_code         = "404"
    error_caching_min_ttl = 1
  }

  viewer_certificate {
    acm_certificate_arn      = var.meister_lol_certificate_us_east_1
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  tags = {
    Project = "dp1000"
  }
}

####---- CodePipeline ----####

resource "aws_codepipeline" "dp1000_codepipeline" {
  name     = "dp1000_codepipeline"
  role_arn = aws_iam_role.dp1000_pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.dp1000_codepipelineartifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Update_from_GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["SourceArtifact"]
      configuration = {
        BranchName           = "main"
        ConnectionArn        = aws_codestarconnections_connection.OmerMeister_GitHub.arn
        FullRepositoryId     = "OmerMeister/dp1000-webcontent"
        OutputArtifactFormat = "CODE_ZIP"
      }

      run_order = 1
      region    = "us-east-1"
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy_to_S3"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = []


      configuration = {
        BucketName = aws_s3_bucket.dp1000_webcontent.bucket
        Extract    = "true"
      }

      run_order = 1
      region    = "us-east-1"
      namespace = "DeployVariables"
    }
  }

  stage {
    name = "InvalidateCloudFront"

    action {
      name             = "InvalidateCloudFront_Lambda"
      category         = "Invoke"
      owner            = "AWS"
      provider         = "Lambda"
      version          = "1"
      input_artifacts  = []
      output_artifacts = []


      configuration = {
        FunctionName = aws_lambda_function.dp1000_lambda1.function_name
      }

      run_order = 1
      region    = "us-east-1"
    }
  }

  tags = {
    Project = "dp1000"
  }
}