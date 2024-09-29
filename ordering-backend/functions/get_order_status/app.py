import json
import boto3
import os
from boto3.dynamodb.conditions import Key
from decimal import Decimal
import traceback
from aws_lambda_powertools import Logger, Tracer, Metrics

logger = Logger(service="OrdersBackend")
tracer = Tracer(service="OrdersBackend")
metrics = Metrics(namespace="OrdersBackend", service="OrdersBackend")

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['ORDERS_TABLE'])

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            if obj.to_integral() != obj:
                return float(obj)
            else:
                return int(obj)
        return super(DecimalEncoder, self).default(obj)
    
@tracer.capture_lambda_handler
@logger.inject_lambda_context(log_event=True)
@metrics.log_metrics(capture_cold_start_metric=True)
def lambda_handler(event, context):
    try:
        order_id = event['pathParameters']['orderId']

        response = table.get_item(Key={'orderId': order_id})
        
        if 'Item' in response:
            found_item = response['Item']
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                },
                'body': json.dumps(found_item, cls=DecimalEncoder)  
            }
        else:
            return {
                'statusCode': 404,
                'body': json.dumps({'message': 'Order not found'})
            }
    except Exception as e:
        traceback.print_exc()
        logger.info(f"traceback={traceback.format_exc()}")   
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }