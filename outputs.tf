output "lambda_function_name" {
  value = aws_lambda_function.serverless_stack_function.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.api_items_table.name
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
