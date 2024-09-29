provider "aws" {
  # profile = var.aws_profile
  region  = var.aws_region
}

// Get current account info
data "aws_caller_identity" "current" {}

# Get all possible AZs
data "aws_availability_zones" "available_azs" {}

# Setup VPC
resource "aws_vpc" "main_network" {
  cidr_block = "172.0.0.0/16"
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Setup public subnets - one for each az
resource "aws_subnet" "private_subnet" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main_network.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_azs.names[count.index]
  vpc_id            = aws_vpc.main_network.id
  tags = {
    Name = "${var.project_name}-private-subnet-${count.index}"
  }
}

# Setup public subnets - one for each az
resource "aws_subnet" "public_subnet" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main_network.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  vpc_id                  = aws_vpc.main_network.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }
}

# Define internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_network.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main_network.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Define NAT gateway for each private subnet
resource "aws_eip" "nat_gateway_eip" {
  count      = var.az_count
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "${var.project_name}-nat-gateway-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.nat_gateway_eip.*.id, count.index)
  tags = {
    Name = "${var.project_name}-nat-gateway-${count.index}"
  }
}

# Create route table for each private subnet
resource "aws_route_table" "private_route_table" {
  count  = var.az_count
  vpc_id = aws_vpc.main_network.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  }

  tags = {
    Name = "${var.project_name}-NAT-Gateway-rt-${count.index}"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main_network.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Associate route tables with private subnets
resource "aws_route_table_association" "private_route_table_association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

# VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main_network.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
}

# Associate VPC endpoint for S3 with private route tables
resource "aws_vpc_endpoint_route_table_association" "s3_endpoint_rt_association" {
  count           = var.az_count
  route_table_id  = element(aws_route_table.private_route_table.*.id, count.index)
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

# Define Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.project_name}"
}

# Define Log stream
resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${var.task_container_name_process_order}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

# Define Log stream
resource "aws_cloudwatch_log_stream" "log_stream_deliver_order" {
  name           = "${var.task_container_name_deliver_order}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

data "aws_ssm_parameter" "api_key" {
  name = var.api_key_in_ssm
}

resource "aws_cloudwatch_event_connection" "momento_topic" {
  name               = "momento-topic-conn"
  description        = "momento-topic-conn"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "Authorization"
      value = data.aws_ssm_parameter.api_key.value
    }
  }
}
