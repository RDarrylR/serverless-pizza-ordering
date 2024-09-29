[
  {
    "cpu": ${fargate_cpu},
    "essential": true,
    "image": "${app_image}",
    "memory": ${fargate_memory},
    "name": "${task_container_name}",
    "runtimePlatform": {
        "cpuArchitecture": "ARM64",
        "operatingSystemFamily": "LINUX"
    },
    "environment": [
      {"name": "TASK_TOKEN", "value": "ABC_TOKEN"},
      {"name": "ORDERS_TABLE_NAME", "value": "OrdersTable"},
      {"name": "ORDER_ID", "value": ""}      
    ],    
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${project_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "${project_name}-log-stream"
      }
    }
  },
  {
    "image": "public.ecr.aws/aws-observability/aws-otel-collector:v0.35.0",
    "name": "aws-otel-collector",
    "command": ["--config=/etc/ecs/ecs-cloudwatch.yaml"],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${project_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "${project_name}-otel-sidecar-log-stream"
      }
    }
  }  
]

