locals {
  notification_id = var.notification_id
  bucket = var.s3_bucket_name
  lambda_arn = var.lambda_arn
  events = var.events
  prefix = var.prefix
  suffix = var.suffix
  aws_profile = var.aws_profile
}

data "aws_region" "current" {}

resource "null_resource" "s3_object_created_subscription" {
  triggers = {
    prefix = local.prefix
    suffix = local.suffix
    events = local.events
    lambda_arn = local.lambda_arn
    notification_id = local.notification_id
    bucket = local.bucket
    aws_profile = local.aws_profile
    aws_region = data.aws_region.current.name
  }

  provisioner "local-exec" {
    command = "ruby update_s3_notification.rb --bucket ${self.triggers.bucket} --arn ${self.triggers.lambda_arn} --events ${self.triggers.events} --prefix '${self.triggers.prefix}' --suffix '${self.triggers.suffix}' --id '${self.triggers.notification_id}'"
    working_dir= path.module
    environment = {
      "AWS_PROFILE" = self.triggers.aws_profile
      "AWS_REGION" = self.triggers.aws_region
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "ruby update_s3_notification.rb --bucket ${self.triggers.bucket} --arn ${self.triggers.lambda_arn} --events ${self.triggers.events} --prefix '${self.triggers.prefix}' --suffix '${self.triggers.suffix}' --id '${self.triggers.notification_id}' --delete"
    working_dir=path.module
    environment = {
      "AWS_PROFILE" = self.triggers.aws_profile
      "AWS_REGION" = self.triggers.aws_region
    }
  }
}