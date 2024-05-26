locals {
  layer_zip_path    = "layer.zip"
  layer_name        = "my_lambda_requirements_layer"
  requirements_path = "${var.lambda_root}/requirements.txt"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "consumer_function"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = var.handler
  role             = aws_iam_role.lambda_iam_role.arn
  runtime          = var.runtime
  timeout          = 360
  layers           = [aws_lambda_layer_version.my-lambda-layer.arn]

  environment {
    variables = {
      client_id     = "${var.client_id}"
      client_secret = "${var.client_secret}"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}

# create zip file for layers from requirements.txt. Triggers only when the file is updated
resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = <<EOT
      pip install -r ${var.lambda_root}/requirements.txt -t python/
      zip -r ${local.layer_zip_path} python/
    EOT
  }

  triggers = {
    dependencies_versions = filemd5("${var.lambda_root}/requirements.txt")
  }
}

# upload zip file to s3
resource "aws_s3_object" "lambda_layer_zip" {
  bucket     = aws_s3_bucket.s3_eventbridge_api_bucket.id
  key        = "lambda_layers/${local.layer_name}/${local.layer_zip_path}"
  source     = local.layer_zip_path
  depends_on = [null_resource.install_dependencies] # triggered only if the zip file is created
}

# create lambda layer from s3 object
resource "aws_lambda_layer_version" "my-lambda-layer" {
  s3_bucket           = aws_s3_bucket.s3_eventbridge_api_bucket.id
  s3_key              = aws_s3_object.lambda_layer_zip.key
  layer_name          = local.layer_name
  compatible_runtimes = [var.runtime]
  skip_destroy        = true
  depends_on          = [aws_s3_object.lambda_layer_zip] # triggered only if the zip file is uploaded to the bucket
}

resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(var.lambda_root, var.lambda_file_name),
      fileset(var.lambda_root, "requirements.txt")
    ) :
    filename => filemd5("${var.lambda_root}/${filename}")
  }
}

# define zip for lambda
data "archive_file" "lambda_zip_file" {
  source_file = "${var.lambda_root}/lambda.py"
  output_path = "${random_uuid.lambda_src_hash.result}.zip"
  type        = "zip"
}
