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

data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/python/"
output_path = "${path.module}/python/lambda.zip"
}

resource "aws_cloudwatch_event_rule" "hourly-cloudwatch" {
  name = "every-hour"
  
  schedule_expression = "cron(30 * * * ? *)"

}

resource "aws_lambda_function" "lambda_emailer" {
     
  filename = "${path.module}/python/lambda.zip"
  function_name = "weather_emailer"
  handler = "lambda_handler.lambda_handler"
  runtime = "python3.9"
  role = aws_iam_role.lambda_role.arn
  source_code_hash =  "${data.archive_file.zip_the_python_code.output_base64sha256}"
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