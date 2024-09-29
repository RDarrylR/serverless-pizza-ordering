
variable "project_name" {
  default = "cloud-pizzeria"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "lambda_root" {
  default = "../functions"
}

variable "az_count" {
  default = "2"
}

variable "task_container_name_process_order" {
  default = "pizzeria-order-processor"
}

variable "task_container_name_deliver_order" {
  default = "pizzeria-order-delivery"
}

variable "task_definition_process_order" {
  default = "pizzeria_order_processor_fargate"
}

variable "task_definition_deliver_order" {
  default = "pizzeria_order_delivery_fargate"
}

variable "fargate_cpu" {
  default = "256"
}

variable "fargate_memory" {
  default = "512"
}

variable "momento_cache_name" {
  default = "pizza-orders"
}

variable "momento_topic_prefix" {
  default = "order-"
}

variable "momento_topics_endpoint" {
  default = "https://api.cache.cell-us-east-1-1.prod.a.momentohq.com/topics"
}
variable "lambda_identity_timeout" {
  default = "300"
}

variable "api_key_in_ssm" {
  default = "/dev/pizza/momento-api-key"
}