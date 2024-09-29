
resource "aws_lambda_layer_version" "create_order_layer" {
  layer_name          = "create_order_layer"
  filename            = "../functions/create_order_docker_layer.zip"
  compatible_runtimes = ["python3.12"]
  compatible_architectures = ["arm64"]
}

data "archive_file" "create_order" {
  type        = "zip"
  source_dir  = "../functions/create_order"
  output_path = "../functions/build/create_order.zip"
  excludes = [
    "__pycache__",
    "venv",
    "layer"
  ]
}

resource "aws_lambda_function" "create_order" {
  function_name = "create_order"
  timeout       = 60
  handler       = "app.lambda_handler"
  runtime       = "python3.12"
  architectures = ["arm64"]
  memory_size   = 1024
  layers        = [
    "arn:aws:lambda:us-east-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python312-arm64:1",
    aws_lambda_layer_version.create_order_layer.arn
    ]

  filename         = data.archive_file.create_order.output_path
  source_code_hash = data.archive_file.create_order.output_base64sha256
  role             = aws_iam_role.orders_lambda_execution_role.arn
  environment {
    variables = {
      ORDERS_TABLE      = aws_dynamodb_table.orders_table.name
      STATE_MACHINE_ARN = aws_sfn_state_machine.pizza_order_state_machine.arn
      API_KEY_IN_SSM    = var.api_key_in_ssm
      MOMENTO_CACHE_NAME = var.momento_cache_name
      MOMENTO_TOPIC_PREFIX = var.momento_topic_prefix
    }
  }
  tracing_config {
    mode = "Active"
  }
}


data "archive_file" "get_order_status" {
  type        = "zip"
  source_dir  = "../functions/get_order_status"
  output_path = "../functions/build/get_order_status.zip"
  excludes = [
    "__pycache__",
    "venv",
    "layer"
  ]
}

resource "aws_lambda_function" "get_order_status" {
  function_name = "get_order_status"
  timeout       = 60
  handler       = "app.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 1024
  architectures = ["arm64"]
  layers        = ["arn:aws:lambda:us-east-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python312-arm64:1"]

  filename         = data.archive_file.get_order_status.output_path
  source_code_hash = data.archive_file.get_order_status.output_base64sha256
  role             = aws_iam_role.orders_lambda_execution_role.arn

  environment {
    variables = {
      ORDERS_TABLE = aws_dynamodb_table.orders_table.name
    }
  }
  tracing_config {
    mode = "Active"
  }
}


resource "aws_iam_role" "orders_lambda_execution_role" {
  name = "orders_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
  ] })

  inline_policy {
    name = "s3_upload_handler_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:*",
            "ssm:GetParameter",
            "states:StartExecution",
            "dynamodb:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "get_orders_policy_BasicExecutionRole_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.orders_lambda_execution_role.name
}


resource "aws_lambda_permission" "create_order_allow_api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.pizza_ordering_api.execution_arn}/*/*"
}

# The resource policy on the create_order Lambda function that allows API GW to run it
resource "aws_lambda_permission" "get_order_status_allow_api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_order_status.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.pizza_ordering_api.execution_arn}/*/*"
}

data "archive_file" "process_dynamodb_stream" {
  type        = "zip"
  source_dir  = "../functions/process_dynamodb_stream"
  output_path = "../functions/build/process_dynamodb_stream.zip"
  excludes = [
    "__pycache__",
    "venv",
    "layer"
  ]
}

resource "aws_lambda_function" "process_dynamodb_stream" {
  function_name = "process_dynamodb_stream"
  timeout       = 60
  handler       = "app.lambda_handler"
  runtime       = "python3.12"
  architectures = ["arm64"]
  memory_size   = 1024
  layers        = ["arn:aws:lambda:us-east-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python312-arm64:1"]

  filename         = data.archive_file.process_dynamodb_stream.output_path
  source_code_hash = data.archive_file.process_dynamodb_stream.output_base64sha256
  role             = aws_iam_role.orders_lambda_execution_role.arn

  environment {
    variables = {
      ORDERS_TABLE = aws_dynamodb_table.orders_table.name
      STATE_MACHINE_ARN = aws_sfn_state_machine.pizza_order_state_machine.arn
    }
  }
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.orders_table.stream_arn
  function_name     = aws_lambda_function.process_dynamodb_stream.arn
  function_response_types = ["ReportBatchItemFailures"]
  starting_position = "LATEST"
}

