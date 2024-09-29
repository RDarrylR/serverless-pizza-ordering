resource "aws_api_gateway_rest_api" "pizza_ordering_api" {
  name = "pizza_ordering_api"
  body = templatefile("${path.module}/../apis/pizza-ordering-api-openapi-definition-json.tpl", {
    aws_region          = var.aws_region
    get_order_status_arn = aws_lambda_function.get_order_status.arn
    create_order_arn     = aws_lambda_function.create_order.arn
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "dev" {
  rest_api_id = aws_api_gateway_rest_api.pizza_ordering_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.pizza_ordering_api.body,
      aws_api_gateway_rest_api.pizza_ordering_api.root_resource_id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.dev.id
  rest_api_id   = aws_api_gateway_rest_api.pizza_ordering_api.id
  stage_name    = "dev"
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.pizza_ordering_api.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

# Add this new resource to enable CORS
resource "aws_api_gateway_gateway_response" "cors" {
  rest_api_id = aws_api_gateway_rest_api.pizza_ordering_api.id
  status_code = "200"
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
  }
}
