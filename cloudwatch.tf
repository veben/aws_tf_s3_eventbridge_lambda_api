resource "aws_cloudwatch_event_rule" "event_rule" {
  name_prefix = "eventbridge-lambda-"
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Access Tier Changed", "Object ACL Updated", "Object Created", "Object Deleted", "Object Restore Completed", "Object Restore Expired", "Object Restore Initiated", "Object Storage Class Changed", "Object Tags Added", "Object Tags Deleted"],
    "detail" : {
      "bucket" : {
        "name" : ["${aws_s3_bucket.s3_eventbridge_api_bucket.id}"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "target_lambda_function" {
  rule = aws_cloudwatch_event_rule.event_rule.name
  arn  = aws_lambda_function.lambda_function.arn
}
