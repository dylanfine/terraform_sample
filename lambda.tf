data "aws_iam_policy_document" "policy_data" {

    statement {
        effect = "Allow"
        actions = ["*"]
        resources = ["*"]

    }
  
}

data "aws_iam_policy_document" "iam_lambda_service" {

    statement {
        effect = "Allow"
        principals {
          type = "Service"
          identifiers=["lambda.amazonaws.com"]
        }
    actions = ["sts:AssumeRole"]
    }
  
}

resource "aws_iam_policy" "lambda_role_policy" {
  name = "lambda_role_policy"
  policy = data.aws_iam_policy_document.policy_data.json
}

resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"
    assume_role_policy = data.aws_iam_policy_document.iam_lambda_service.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.lambda_role_policy.arn
  
}

data "archive_file" "zip_weather_lambda" {
type        = "zip"
source_dir  = "${path.module}/python/weather_lambda"
output_path = "${path.module}/python/zips/weather_lambda.zip"
}

data "archive_file" "zip_transfer_lambda" {
type        = "zip"
source_dir  = "${path.module}/python/s3_transfer_lambda"
output_path = "${path.module}/python/zips/s3_transfer_lambda.zip"
}



resource "aws_cloudwatch_event_rule" "hourly-cloudwatch" {
  name = "every-hour"
  
  schedule_expression = "cron(30 * * * ? *)"

}

resource "aws_lambda_function" "lambda_emailer" {
     
  filename = data.archive_file.zip_weather_lambda.output_path
  function_name = "weather_emailer"
  handler = "lambda_handler.lambda_handler"
  runtime = "python3.9"
  role = aws_iam_role.lambda_role.arn
  source_code_hash =  "${data.archive_file.zip_weather_lambda.output_base64sha256}"
  timeout = 30
} 

resource "aws_cloudwatch_event_target" "cloudwatch_to_lambda" {
  rule = aws_cloudwatch_event_rule.hourly-cloudwatch.name
  arn = aws_lambda_function.lambda_emailer.arn

}

resource "aws_lambda_permission" "cloudwatch-perm" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_emailer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.hourly-cloudwatch.arn
}


resource "aws_lambda_function" "s3_transfer_lambda" {
     
  filename = data.archive_file.zip_transfer_lambda.output_path
  function_name = "s3_transfer"
  handler = "lambda_handler.lambda_handler"
  runtime = "python3.9"
  role = aws_iam_role.lambda_role.arn
  source_code_hash =  "${data.archive_file.zip_transfer_lambda.output_base64sha256}"
  timeout = 30
} 



resource "aws_s3_bucket_notification" "s3_notification" {
    bucket = aws_s3_bucket.input_bucket.id

    lambda_function {
      lambda_function_arn = aws_lambda_function.s3_transfer_lambda.arn
      events = ["s3:ObjectCreated:*"]
    }
    
    depends_on = [
        aws_lambda_permission.allow_s3_notification
    ]
}

resource "aws_lambda_permission" "allow_s3_notification" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.s3_transfer_lambda.function_name
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.input_bucket.arn
  
}