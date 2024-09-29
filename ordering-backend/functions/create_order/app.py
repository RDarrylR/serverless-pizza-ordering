import json
import uuid
import boto3
import os
from datetime import datetime, UTC
from decimal import Decimal
from typing import Dict, Any
from datetime import timedelta

import traceback
from aws_lambda_powertools import Logger, Tracer, Metrics
from botocore.exceptions import ClientError
from momento.utilities import ExpiresIn
from momento import AuthClient
from momento.auth.access_control.disposable_token_scopes import DisposableTokenScopes
from momento import (
    Configurations,
    CredentialProvider
)
from momento.responses import GenerateDisposableToken

logger = Logger(service="OrdersBackend")
tracer = Tracer(service="OrdersBackend")
metrics = Metrics(namespace="OrdersBackend", service="OrdersBackend")

dynamodb = boto3.resource('dynamodb')
stepfunctions = boto3.client('stepfunctions')
ssm = boto3.client('ssm')
table = dynamodb.Table(os.environ['ORDERS_TABLE'])
api_key = ssm.get_parameter(Name=os.environ['API_KEY_IN_SSM'], WithDecryption=True)['Parameter']['Value']
momento_cache_name = os.environ['MOMENTO_CACHE_NAME']
momento_topic_prefix = os.environ['MOMENTO_TOPIC_PREFIX']
momento_api_key = CredentialProvider.from_string(api_key)

momento_auth_client = AuthClient(
    Configurations.Lambda.latest(),
    CredentialProvider.from_string(api_key)
)

@tracer.capture_lambda_handler
@logger.inject_lambda_context(log_event=True)
@metrics.log_metrics(capture_cold_start_metric=True)
def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    try:
        body: Dict[str, Any] = json.loads(event['body'], parse_float=Decimal)
        order_id: str = str(uuid.uuid4())
        timestamp: str = datetime.now(UTC).isoformat()
            
        item: Dict[str, Any] = {
            'orderId': order_id,
            'timestamp': timestamp,
            'status': 'PENDING',
            'items': body.get('items', []),
            'customer': body.get('customer', {}),
            'orderType': body.get('orderType', ''),
            'totalAmount': body.get('totalAmount', 0)
        }  
        
        table.put_item(Item=item)
        
        # Create an auth token so the user can track their order using the momento topic for the order
        momento_response = momento_auth_client.generate_disposable_token(
                    DisposableTokenScopes.topic_subscribe_only(momento_cache_name, f"{momento_topic_prefix}{order_id}"),
                    ExpiresIn.minutes(60))
        
        match momento_response:
            case GenerateDisposableToken.Success():
                logger.info("Successfully generated a disposable token", 
                            extra={
                                "auth_token": momento_response.auth_token,
                                "endpoint": momento_response.endpoint
                            })
            case GenerateDisposableToken.Error() as error:
                logger.info(f"Error generating a disposable token", 
                            extra={"error": error.message})
                        
        return {
            'statusCode': 201,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps(
                {
                    'orderId': order_id, 
                    'message': 'Order created successfully',
                    'token': momento_response.auth_token if hasattr(momento_response, 'auth_token') else None
                })
        }
    except Exception as e:
        traceback.print_exc()
        logger.info(f"traceback={traceback.format_exc()}")   
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }