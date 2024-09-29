#/bin/sh

AWS_ACCOUNT_NUMBER=`aws sts get-caller-identity --query 'Account' --output text`
AWS_REGION=`aws configure get region`

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com
aws ecr create-repository --repository-name fargate_rust_order_delivery

docker build -t ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com/fargate_rust_order_delivery:latest .
docker push ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com/fargate_rust_order_delivery:latest
