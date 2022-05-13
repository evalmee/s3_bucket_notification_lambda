# s3_bucket_notification_lambda

A module to create a S3 notification to a lambda function.

The [module provided by AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) manage S3 notifications as one resource and only support a single notification configuration. (See issue https://github.com/hashicorp/terraform-provider-aws/issues/501)

With this module, you can manage your S3 notifications from different terraform stacks.

⚠️ **Warning:** 
- This module only support S3 notifications to a lambda function. Other notifications created for the source bucket will be overwritten.
- This module is in alpha state and is not recommended for production.


## Example

```hcl
module "s3-notification" {
  source = "github.com/evalmee/s3_bucket_notification_lambda"

  s3_bucket_name = "your-bucket-name"
  lambda_arn = "your-lambda-arn"
  events = "s3:ObjectCreated:*"
  prefix = "foo"
  suffix = ".jpeg"
  notification_id = "image upload notification"
}
```

## How does it work?

This module retrieves the current S3 notification configuration from the bucket and merge the new configuration with the existing one.
The notification name is used as identifier.

## Requirement
This module executes a Ruby script to manage the S3 notifications.
You need a working Ruby installation (version >2.6) to use this module.