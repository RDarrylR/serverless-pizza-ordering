resource "aws_sfn_state_machine" "pizza_order_state_machine" {
  name     = "Process-Pizza-Order-State-Machine"
  role_arn = aws_iam_role.step_function_role.arn

  definition = templatefile(
    "../state-machines/step-function-json.tpl",
    {
      momento_topic_connection_arn = "${aws_cloudwatch_event_connection.momento_topic.arn}"
      momento_topics_endpoint      = "${var.momento_topics_endpoint}"
      cache_name                   = var.momento_cache_name
      topic_prefix                 = var.momento_topic_prefix
      ecs_cluster                  = "${aws_ecs_cluster.ecs_cluster.arn}"
      processing_task_def_name     = "${var.task_definition_process_order}"
      delivery_task_def_name       = "${var.task_definition_deliver_order}"
      vpc_default_sg               = "${aws_default_security_group.default.id}"
      fargate_subnet               = "${aws_subnet.private_subnet[0].id}"
    }
  )
}

# Set policy for step function
resource "aws_iam_policy" "step_function_policy" {
  name = "step_function_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetBucket*",
          "s3:GetObject*",
          "s3:List*",
          "states:StartExecution",
          "states:InvokeHTTPEndpoint",
          "events:RetrieveConnectionCredentials",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "ecs:RunTask",
          "iam:PassRole",
          "events:*",
          "logs:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }

    ]
  })
}

# Set exection role for step function
resource "aws_iam_role" "step_function_role" {
  name = "${var.project_name}-step-function-role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "states.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "step_functions_policy_attachment" {
  policy_arn = aws_iam_policy.step_function_policy.arn
  role       = aws_iam_role.step_function_role.name
}
