#!/usr/bin/env ruby

require 'bundler/inline'
require 'optparse'

gemfile do
  source 'https://rubygems.org'
  gem 'aws-sdk'
  gem 'byebug'
end

bucket_name = ''
delete = false

lambda_notification_input = {}
OptionParser.new do |opts|
  opts.banner = "update_s3_notifiaction.rb --bucket bucket_name --arn your_lambda_arn --events 's3:ObjectCreated:Put'  -i 'my notification'"
  
  opts.on("-bBUCKET", "--bucket BUCKET", "Bucket name") do |v|
    bucket_name = v
  end
  
  opts.on("-iID", "--idID", "Notification id") do |v|
    lambda_notification_input[:id] = v
  end
  
  opts.on("-aARN", "--arn ARN", "Lambda ARN") do |v|
    lambda_notification_input[:lambda_function_arn] = v
  end

  opts.on("-eEVENTS", "--events EVENTS", "Events array") do |v|
    lambda_notification_input[:events] = v.split(",")
  end

  opts.on("-pPREFIX", "--prefix PREFIX", "prefix filter") do |v|
    lambda_notification_input[:prefix] = v.empty? ? nil : v
  end

  opts.on("-sSUFFIX", "--suffix SUFFIX", "suffix filter") do |v|
    lambda_notification_input[:suffix] = v.empty? ? nil : v
  end

  opts.on("-d", "--delete", "delete the notification with the specified id") do |v|
    delete = v
  end
end.parse!

puts "#################"
puts "Lambda Notification to create/update: #{lambda_notification_input}"
puts "#################"



class S3Notifications
  
  attr_reader :bucket_name, :lambda_notification_input, :existing_lambda_configurations, :bucket_notification
  
  def initialize(bucket_name, lambda_notification_input)
    @bucket_name = bucket_name
    @lambda_notification_input = lambda_notification_input
    @bucket_notification = Aws::S3::BucketNotification.new(bucket_name)
    @existing_lambda_configurations = bucket_notification.data.lambda_function_configurations
    
    raise "Bucket name is required" if bucket_name.empty?
  end
  
  def update
    puts new_lambda_configurations.map(&:to_h)
    bucket_notification.put({ notification_configuration: {
      lambda_function_configurations: new_lambda_configurations.map(&:to_h)}
    })
  end
  
  def delete
    puts "Deleting lambda configuration: #{lambda_notification_input[:id]}"
    
    lambda_config = existing_lambda_configurations.select do |configuration|
      configuration.id != lambda_notification_input[:id]
    end

    bucket_notification.put({ notification_configuration: {
      lambda_function_configurations: lambda_config.map(&:to_h)}
                            })
  end
  
  private
  
  def new_lambda_configuration
    Aws::S3::Types::LambdaFunctionConfiguration.new(
      **lambda_notification_input.select{|k,v| [:id, :lambda_function_arn ,:events].include? k},
      filter: filters
    )
  end
  
  def filters
    
    rules = [
      {
        name: "suffix",
        value: lambda_notification_input[:suffix],
      },
      {
        name: "prefix",
        value: lambda_notification_input[:prefix],
      },
    ].select { |rule| rule[:value] }
    
    return nil if rules.empty?
    
    { key: { filter_rules: rules } }
  end
  
  def new_lambda_configurations
    return existing_lambda_configurations + [new_lambda_configuration] unless config_already_exist?

    existing_lambda_configurations.map do |lambda_config|
      lambda_config.id == new_lambda_configuration.id ? new_lambda_configuration : lambda_config
    end
  end
  
  def config_already_exist?
    existing_lambda_configurations.any? { |configuration| configuration.id == new_lambda_configuration.id }
  end
end

if delete
  S3Notifications.new(bucket_name, lambda_notification_input).delete
else
  S3Notifications.new(bucket_name, lambda_notification_input).update
end
