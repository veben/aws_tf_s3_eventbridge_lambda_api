resource "aws_s3_bucket" "s3_eventbridge_api_bucket" {
  bucket = var.bucket_name

  force_destroy = true
}

# Send notifications to EventBridge for all events in the bucket
resource "aws_s3_bucket_notification" "s3_eventbridge_api_bucket_notification" {
  bucket      = aws_s3_bucket.s3_eventbridge_api_bucket.id
  eventbridge = true
}
