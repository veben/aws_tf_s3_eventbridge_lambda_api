data "aws_iam_policy" "lambda_basic_execution_role_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.pattern_name}-lambda-policy"
  description = "Policy to allow to interact with s3 bucket"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:CopyObject",
        "s3:HeadObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "${var.pattern_name}-lambda-role"
  managed_policy_arns = [data.aws_iam_policy.lambda_basic_execution_role_policy.arn, aws_iam_policy.lambda_policy.arn]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": "sts:AssumeRole",
	  "Principal": {
		"Service": "lambda.amazonaws.com"
	  },
	  "Effect": "Allow",
	  "Sid": ""
	}
  ]
}
EOF
}
