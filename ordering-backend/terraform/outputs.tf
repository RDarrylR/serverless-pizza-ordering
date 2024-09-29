output "ordering_api_url" {
  value = "${aws_api_gateway_deployment.dev.invoke_url}${aws_api_gateway_stage.dev.stage_name}/orders"
}
