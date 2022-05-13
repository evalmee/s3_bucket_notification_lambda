variable "s3_bucket_name" {
  description = "The name of the S3 bucket emitting the notification"
}

variable "lambda_arn" {
  description = "The arn of the lambda"
}

variable "events" {
  description = "Events, separated by a comma"
}

variable "prefix" {
  description = "Prefix to filter on"
  default = ""
}

variable "suffix" {
  description = "Suffix to filter on"
  default = ""
}

variable "notification_id" {
  description = "The name of the notification"
}

variable "aws_profile" {
  description = "The name of the aws profile"
  default = "default"
}