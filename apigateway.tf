#================================================================
# COMPONENT: API Gateway
# Description: Defines the core HTTP API and its public stage.
#================================================================
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.iam_role_name}_webapp_api"
  protocol_type = "HTTP"
  tags = {
    iam_role_name = var.iam_role_name
  }
}
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "${var.iam_role_name}_default"
  auto_deploy = true
  tags = {
    iam_role_name = var.iam_role_name
  }
   access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
        "requestId"          = "$context.requestId",
        "ip"                 = "$context.identity.sourceIp",
        "requestTime"        = "$context.requestTime",
        "httpMethod"         = "$context.httpMethod",
        "routeKey"           = "$context.routeKey",
        "status"             = "$context.status",
        "protocol"           = "$context.protocol",
        "responseLength"     = "$context.responseLength",
        "integrationError"   = "$context.integration.error",
        "authorizerError"    = "$context.authorizer.error"
    })
  }
}

#================================================================
# COMPONENT: Backend Lambda Integration
# Description: Configures the integration with the primary web application Lambda.
#================================================================

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.web_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "api_gateway_invoke-web_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.web_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}


#================================================================
# COMPONENT: Authorizer & Secured Route
# Description: Defines the custom authorizer and the specific route it protects.
#================================================================


resource "aws_apigatewayv2_authorizer" "pat_lambda_auth" {
  name                       = "${var.iam_role_name}_pat_lambda_authorizer"
  api_id                     = aws_apigatewayv2_api.http_api.id
  authorizer_type            = "REQUEST"
  authorizer_uri             = aws_lambda_function.pat_auth_lambda.invoke_arn
  identity_sources           = ["$request.header.Authorization"]
  authorizer_payload_format_version = "2.0"
}

resource "aws_lambda_permission" "api_gateway_invoke_auth_lambda" {
  statement_id  = "AllowAPIGatewayInvokeAuthLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pat_auth_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.pat_lambda_auth.id}"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /fruit"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  #authorization_type = "CUSTOM"
  #authorizer_id      = aws_apigatewayv2_authorizer.pat_lambda_auth.id
  authorization_type = "NONE"

  # it must destroy this route before it can destroy the authorizer and integration.
  depends_on = [
    aws_apigatewayv2_authorizer.pat_lambda_auth,
    aws_apigatewayv2_integration.lambda_integration
  ]
}




