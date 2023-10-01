####---- s3 buckets ----####

# create an empty s3 bucket
resource "aws_s3_bucket" "meister_lol_s3_bucket" {
  bucket = "tf_static_site.meister.lol" #bucket name

  tags = {
    Name        = "tf_static_site.meister.lol"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket" "artifact_bucket_static_site_pipeline" {
  bucket = "artifact_tf_static_site.meister.lol" #bucket name

  tags = {
    Name        = "artifact_tf_static_site.meister.lol"
    Environment = "Prod"
  }
}


# policy document for the tf_static_site bucket to allow getobject and listbucket from cloudfront
# these settings enable webpages display and 404 error from couldfront

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

# attaching the policy document to the tf_static_site bucket

resource "aws_s3_bucket_policy" "allow_readget_access_cloudfront_to_s3" {
  bucket = aws_s3_bucket.meister_lol_s3_bucket.id
  policy = data.aws_iam_policy_document.allow_readget_access_cloudfront_to_s3.json
}

# add static website hosting settings to the tf_static_site bucket

resource "aws_s3_bucket_website_configuration" "meister_lol_s3_bucket_webconfig" {
  bucket = aws_s3_bucket.meister_lol_s3_bucket.id
}


####---- roles ----####
####---- role1 ----####

resource "aws_iam_policy" "example_policy" {
  name        = "AWSCodePipelineServiceRole-eu-central-1-tf-static-site-GitHub-to-S3"
  description = "Policy used in trust relationship with CodePipeline"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "iam:PassRole",
        ],
        Resource = "*",
        Effect = "Allow",
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
        Effect = "Allow",
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
        Effect = "Allow",
      },
      {
        Action = [
          "codestar-connections:UseConnection",
        ],
        Resource = "*",
        Effect = "Allow",
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
        Effect = "Allow",
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:ListFunctions",
        ],
        Resource = "*",
        Effect = "Allow",
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
        Effect = "Allow",
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
        Effect = "Allow",
      },
      {
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch",
        ],
        Resource = "*",
        Effect = "Allow",
      },
      {
        Effect   = "Allow",
        Action   = [
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
        Effect   = "Allow",
        Action   = [
          "servicecatalog:ListProvisioningArtifacts",
          "servicecatalog:CreateProvisioningArtifact",
          "servicecatalog:DescribeProvisioningArtifact",
          "servicecatalog:DeleteProvisioningArtifact",
          "servicecatalog:UpdateProduct",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = [
          "cloudformation:ValidateTemplate",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = [
          "ecr:DescribeImages",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = [
          "states:DescribeExecution",
          "states:DescribeStateMachine",
          "states:StartExecution",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = [
          "appconfig:StartDeployment",
          "appconfig:StopDeployment",
          "appconfig:GetDeployment",
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "example_attachment" {
  name       = "example-attachment"
  policy_arn = aws_iam_policy.example_policy.arn
  roles      = [aws_iam_role.example_role.name]
}

resource "aws_iam_role" "example_role" {
  name = "CodePipelineServiceRole-tf-static-site-GitHub-to-S3"

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
}

