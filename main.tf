provider "aws" {
  region = var.aws_region
}

# IAM Role for Lambda
resource "aws_iam_role" "severless_api_lambda_role" {
  name = "severless-api-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach CloudWatch logging policy
resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "attach-lambda-logs"
  roles      = [aws_iam_role.severless_api_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Add DynamoDB write permissions to Lambda role
resource "aws_iam_role_policy" "dynamodb_access" {
  name = "lambda-dynamodb-access"
  role = aws_iam_role.severless_api_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem"
        ],
        Resource = aws_dynamodb_table.api_items_table.arn
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "serverless_stack_function" {
  filename         = "lambda.zip"
  function_name    = "ServerlessStackFunction"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.severless_api_lambda_role.arn
  source_code_hash = filebase64sha256("lambda.zip")

  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group
  ]
}

# Manually create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/ServerlessStackFunction"
  retention_in_days = 7
}

# Lambda Permission: allow API Gateway to invoke
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_stack_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# DynamoDB Table
resource "aws_dynamodb_table" "api_items_table" {
  name         = "Api-Items-Table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "http-api"
  protocol_type = "HTTP"
}

# Lambda Integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.serverless_stack_function.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Route
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}
