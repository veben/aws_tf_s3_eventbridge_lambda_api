variable "region_name" {
  default = "eu-west-1"
}
variable "profile_name" {
  default = "p_lambda_deployer"
}
variable "lambda_root" {
  type        = string
  description = "The relative path to the source of the lambda"
  default     = "./src"
}
variable "lambda_file_name" {
  type        = string
  description = "The lambda source file name"
  default     = "lambda.py"
}
variable "handler" {
  default = "lambda.lambda_handler"
}
variable "runtime" {
  default = "python3.9"
}
variable "client_id" {
  type = string
}
variable "client_secret" {
  type = string
}
variable "bucket_name" {
  default = "s3-eventbridge-api-bucket"
}
variable "pattern_name" {
  default = "s3-eventbridge-api"
}
