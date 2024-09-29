# Define Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Set policy for fargate task (Needs to be tightened up for real use)
resource "aws_iam_policy" "fargate_processor_task_role_policy" {
  name = "fargate_processor_task_role_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Set exection role for fargate task
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

# Set role for fargate task
resource "aws_iam_role" "ecs_task_role" {
  name = "fargate_processor_task_task_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          }
        }
      ]
    }
  )
  managed_policy_arns = [aws_iam_policy.fargate_processor_task_role_policy.arn]
}

# The actual task definition to process the sales data
resource "aws_ecs_task_definition" "fargate_pizza_order_processor_task" {
  family                   = var.task_definition_process_order
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }  
  container_definitions    = templatefile("../ecs-tasks/container-definition-processor.json.tpl",
                              {
                                app_image           = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/fargate_rust_order_processor:latest"
                                fargate_cpu         = "${var.fargate_cpu}"
                                fargate_memory      = "${var.fargate_memory}"
                                aws_region          = "${var.aws_region}"
                                task_container_name = "${var.task_container_name_process_order}"
                                project_name        = "${var.project_name}"
                              })
}

# The actual task definition to process the sales data
resource "aws_ecs_task_definition" "fargate_pizza_delivery_processor_task" {
  family                   = var.task_definition_deliver_order
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  container_definitions    = templatefile("../ecs-tasks/container-definition-delivery.json.tpl",
                              {
                                app_image           = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/fargate_rust_order_delivery:latest"
                                fargate_cpu         = "${var.fargate_cpu}"
                                fargate_memory      = "${var.fargate_memory}"
                                aws_region          = "${var.aws_region}"
                                task_container_name = "${var.task_container_name_deliver_order}"
                                project_name        = "${var.project_name}"
                              })
}



