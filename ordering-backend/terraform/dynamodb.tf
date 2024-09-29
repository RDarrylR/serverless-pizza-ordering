resource "aws_dynamodb_table" "orders_table" {
  name             = "OrdersTable"
  hash_key         = "orderId"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "orderId"
    type = "S"
  }

}