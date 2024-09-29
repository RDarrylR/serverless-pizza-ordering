{
  "Comment": "Process Pizza Order",
  "StartAt": "Order Setup",
  "States": {
    "Order Setup": {
      "Type": "Wait",
      "Seconds": 2,
      "Next": "Send order processing started"
    },
    "Send order processing started": {
      "Type": "Task",
      "Resource": "arn:aws:states:::http:invoke",
      "Parameters": {
        "ApiEndpoint.$": "States.Format('${momento_topics_endpoint}/${cache_name}/${topic_prefix}{}', $$.Execution.Input.orderId)",
        "Method": "POST",
        "Headers": {
          "Content-Type": "application/json"
        },
        "Authentication": {
          "ConnectionArn": "${momento_topic_connection_arn}"
        },
        "RequestBody": {
          "State": "Starting to process order",
          "OrderId.$": "$$.Execution.Input.orderId"
        }
      },
      "Next": "ECS invoke for order processing"
    },
    "ECS invoke for order processing": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.waitForTaskToken",
      "Parameters": {
        "LaunchType": "FARGATE",
        "PlatformVersion": "LATEST",
        "Cluster": "${ecs_cluster}",
        "TaskDefinition": "${processing_task_def_name}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": [
              "${fargate_subnet}"
            ],
            "SecurityGroups": [
              "${vpc_default_sg}"
            ]
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "pizzeria-order-processor",
              "Environment": [
                {
                  "Name": "TASK_TOKEN",
                  "Value.$": "$$.Task.Token"
                },
                {
                  "Name": "ORDER_ID",
                  "Value.$": "$$.Execution.Input.orderId"
                },
                {
                  "Name": "ORDERS_TABLE_NAME",
                  "Value.$": "$$.Execution.Input.ordersTableName"
                },
                {
                  "Name": "ORDER_TYPE",
                  "Value.$": "$$.Execution.Input.orderType"
                }
              ]
            }
          ]
        }
      },
      "Next": "Send order is in oven"
    },    
    "Send order is in oven": {
      "Type": "Task",
      "Resource": "arn:aws:states:::http:invoke",
      "Parameters": {
        "ApiEndpoint.$": "States.Format('${momento_topics_endpoint}/${cache_name}/${topic_prefix}{}', $$.Execution.Input.orderId)",
        "Method": "POST",
        "Headers": {
          "Content-Type": "application/json"
        },
        "Authentication": {
          "ConnectionArn": "${momento_topic_connection_arn}"
        },
        "RequestBody": {
          "State": "Order is in the oven",
          "OrderId.$": "$$.Execution.Input.orderId"
        }
      },
      "Next": "Order is baking"
    },
    "Order is baking": {
      "Type": "Wait",
      "Seconds": 10,
      "Next": "Is this a delivery"
    },    
    "Is this a delivery": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$$.Execution.Input.orderType",
          "StringEquals": "delivery",
          "Next": "Send out delivery"
        }
      ],
      "Default": "Order is ready for pickup"
    },
    "Send out delivery": {
      "Type": "Task",
      "Resource": "arn:aws:states:::http:invoke",
      "Parameters": {
        "ApiEndpoint.$": "States.Format('${momento_topics_endpoint}/${cache_name}/${topic_prefix}{}', $$.Execution.Input.orderId)",
        "Method": "POST",
        "Headers": {
          "Content-Type": "application/json"
        },
        "Authentication": {
          "ConnectionArn": "${momento_topic_connection_arn}"
        },
        "RequestBody": {
          "State": "Sending out delivery",
          "OrderId.$": "$$.Execution.Input.orderId"
        }
      },
      "Next": "ECS invoke for order delivery"
    },
    "ECS invoke for order delivery": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.waitForTaskToken",
      "Parameters": {
        "LaunchType": "FARGATE",
        "PlatformVersion": "LATEST",
        "Cluster": "${ecs_cluster}",
        "TaskDefinition": "${delivery_task_def_name}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": [
              "${fargate_subnet}"
            ],
            "SecurityGroups": [
              "${vpc_default_sg}"
            ]
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "pizzeria-order-delivery",
              "Environment": [
                {
                  "Name": "TASK_TOKEN",
                  "Value.$": "$$.Task.Token"
                },
                {
                  "Name": "ORDER_ID",
                  "Value.$": "$$.Execution.Input.orderId"
                },
                {
                  "Name": "ORDERS_TABLE_NAME",
                  "Value.$": "$$.Execution.Input.ordersTableName"
                }
              ]
            }
          ]
        }
      },
      "Next": "Order was delivered"
    },       
    "Order was delivered": {
      "Type": "Task",
      "Resource": "arn:aws:states:::http:invoke",
      "Parameters": {
        "ApiEndpoint.$": "States.Format('${momento_topics_endpoint}/${cache_name}/${topic_prefix}{}', $$.Execution.Input.orderId)",
        "Method": "POST",
        "Headers": {
          "Content-Type": "application/json"
        },
        "Authentication": {
          "ConnectionArn": "${momento_topic_connection_arn}"
        },
        "RequestBody": {
          "State": "Order was delivered",
          "OrderId.$": "$$.Execution.Input.orderId"
        }
      },
      "End": true
    },
    "Order is ready for pickup": {
      "Type": "Task",
      "Resource": "arn:aws:states:::http:invoke",
      "Parameters": {
        "ApiEndpoint.$": "States.Format('${momento_topics_endpoint}/${cache_name}/${topic_prefix}{}', $$.Execution.Input.orderId)",
        "Method": "POST",
        "Headers": {
          "Content-Type": "application/json"
        },
        "Authentication": {
          "ConnectionArn": "${momento_topic_connection_arn}"
        },
        "RequestBody": {
          "State": "Order is ready for pickup",
          "OrderId.$": "$$.Execution.Input.orderId"
        }
      },
      "End": true
    }
  }
}