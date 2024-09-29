resource "aws_cognito_user_pool" "pizza_user_pool" {
  name                     = "PizzaCustomerUserPool"
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]
  password_policy {
    minimum_length = 8
  }
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = false
  }
}

resource "aws_cognito_user_pool_client" "pizza_user_pool_client" {
  name                = "PizzaCustomerUserPoolClient"
  user_pool_id        = aws_cognito_user_pool.pizza_user_pool.id
  generate_secret     = false
  read_attributes     = ["email_verified"]
  explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

