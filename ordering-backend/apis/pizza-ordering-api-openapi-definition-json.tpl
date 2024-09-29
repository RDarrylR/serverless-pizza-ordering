{
  "openapi": "3.0.1",
  "info": {
    "title": "pizza_ordering_api",
    "version": "1.0"
  },
  "servers": [
    {
      "url": "https://djtcoj3b31.execute-api.${aws_region}.amazonaws.com/{basePath}",
      "variables": {
        "basePath": {
          "default": "dev"
        }
      }
    }
  ],
  "paths": {
    "/orders/{orderId}": {
      "get": {
        "parameters": [
          {
            "name": "orderId",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "200 response",
            "headers": {
              "Access-Control-Allow-Origin": {
                "schema": {
                  "type": "string"
                }
              },
              "Access-Control-Allow-Methods": {
                "schema": {
                  "type": "string"
                }
              },
              "Access-Control-Allow-Headers": {
                "schema": {
                  "type": "string"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration": {
          "httpMethod": "POST",
          "uri": "arn:aws:apigateway:${aws_region}:lambda:path/2015-03-31/functions/${get_order_status_arn}/invocations",
          "passthroughBehavior": "when_no_match",
          "type": "aws_proxy"
        }
      },
      "options": {
        "responses": {
          "200": {
            "description": "200 response",
            "headers": {
              "Access-Control-Allow-Origin": {
                "schema": {
                  "type": "string"
                }
              },
              "Access-Control-Allow-Methods": {
                "schema": {
                  "type": "string"
                }
              },
              "Access-Control-Allow-Headers": {
                "schema": {
                  "type": "string"
                }
              }
            },
            "content": {}
          }
        },
        "x-amazon-apigateway-integration": {
          "responses": {
            "default": {
              "statusCode": "200",
              "responseParameters": {
                "method.response.header.Access-Control-Allow-Methods": "'GET,OPTIONS'",
                "method.response.header.Access-Control-Allow-Headers": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                "method.response.header.Access-Control-Allow-Origin": "'*'"
              }
            }
          },
          "requestTemplates": {
            "application/json": "{\n  \"statusCode\": 200\n}\n"
          },
          "passthroughBehavior": "when_no_match",
          "type": "mock"
        }
      }
    },
    "/orders": {
      "post": {
        "responses": {
          "200": {
            "description": "200 response",
            "headers": {
              "Access-Control-Allow-Origin": {
                "schema": {
                  "type": "string"
                }
              },
              "Access-Control-Allow-Methods": {
                "schema": {
                  "type": "string"
                }
              },
              "Access-Control-Allow-Headers": {
                "schema": {
                  "type": "string"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration": {
          "httpMethod": "POST",
          "uri": "arn:aws:apigateway:${aws_region}:lambda:path/2015-03-31/functions/${create_order_arn}/invocations",
          "passthroughBehavior": "when_no_match",
          "type": "aws_proxy"
        }
      },
      "options": {
        "responses": {
          "200": {
            "description": "200 response",
            "headers": {
              "Access-Control-Allow-Origin": {
                "schema": {
                  "type": "string"
                }
              },
              "Access-Control-Allow-Methods": {
                "schema": {
                  "type": "string"
                }
              },
              "Access-Control-Allow-Headers": {
                "schema": {
                  "type": "string"
                }
              }
            },
            "content": {}
          }
        },
        "x-amazon-apigateway-integration": {
          "responses": {
            "default": {
              "statusCode": "200",
              "responseParameters": {
                "method.response.header.Access-Control-Allow-Methods": "'POST,OPTIONS'",
                "method.response.header.Access-Control-Allow-Headers": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                "method.response.header.Access-Control-Allow-Origin": "'*'"
              }
            }
          },
          "requestTemplates": {
            "application/json": "{\n  \"statusCode\": 200\n}\n"
          },
          "passthroughBehavior": "when_no_match",
          "type": "mock"
        }
      }
    }
  },
  "components": {}
}