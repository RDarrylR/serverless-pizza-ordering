# serverless-pizza-ordering

### Purpose
Example Full-stack Serverless project using ReactJS, Momento Topics, Step Functions, API Gateway, ECS, Lambda, DynamoDB with streams, and more to build an online pizza shop where the progress of orders is updated automatically in the UI.

Containers running in ECS fargate which make and deliver the Pizza orders are coded in Rust.
Lambda functions to handle orders and their progression are coded in Python
Front End is coded using ReactJS.

Backend is deployed using Terraform.

### Key Folder

- `ordering-backend/terraform` - Contains all the files in the Terraform stack to deploy everything in the backend including Step Functions, DynamoDB table, VPC, ECS Cluster, ECS Tasks, Lambda functions, and more.
- `ordering-backend/apis` - Open API spec files for the ordering API Gateway
- `ordering-backend/containers` - scripts and source for the containers that make the pizza and deliver it. Need to run the install script to create ECR repos for the containers and build/push them
- `ordering-backend/ecs-tasks` - ECS Task deifinitions for the Rust ECS workers
- `ordering-backend/functions` - Source code for the Python functions used by the ordering API and DynamoDB Streams handler
- `ordering-backend/state-machines` - Template file for the Step Function 
- `ordering-frontend` - The ReactJS front end for the serverless pizza shop

### Requirements

-   Terraform CLI (https://developer.hashicorp.com/terraform/install)
-   Rust and Cargo tools ([https://www.cargo-lambda.info/guide/getting-started.html](https://www.rust-lang.org/tools/install))
-   Need to setup a Momento Topics API key in the SSM Param Store of the account you deploy to
-   Docker

### Deploy the sample project

To deploy the project, you need to do the following:

1. Clone the repo
2. Setup your Momento Topics API Key in the SSM Param Store of the account you want to install into. Use a SecureString type and the param name should be "/dev/pizza/momento-api-key" or change the variable "api_key_in_ssm" in the "variables.tf" file.
3. Go to the ordering-backend/terraform project
4. Run `terraform init`
5. run `terraform apply` (and type "yes" when it's done with the plan)
6. Note the output from the terraform apply is a URL like this: https://1dwy6zvr05.execute-api.us-east-1.amazonaws.com/dev/orders)
7. Create a .env file in the ordering-frontend\ directory (i.e. ordering-frontend/.env) with contents similar to the included sample-env file in the ordering-frontend folder.
8. In your .env file replace the REACT_APP_ORDERING_API value with the output value from terraform.
9. Change into the ordering-frontend folder
10. run `npm install`
11. run `npm start`
12. The Cloud Pizzeria shop should be display.

### Cleanup

Run the following terraform command to destroy all the infrastructure.

```bash
terraform destroy (from the infra directory)
```

### Read More

This repository is associated with the following blog [HERE](https://darryl-ruggles.cloud/serverless-pizza-ordering)
