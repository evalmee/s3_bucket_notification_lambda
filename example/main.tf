module "s3-notification" {
  source = "../"

  s3_bucket_name = "your-bucket-name"
  lambda_arn = "your-lambda-arn"
  events = "s3:ObjectCreated:*"
  prefix = "foo"
  suffix = ".jpeg"
  notification_id = "image upload notification"
}