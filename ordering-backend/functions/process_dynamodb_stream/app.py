import json
import boto3
import os
from typing import Dict, Any, List
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools.utilities.batch import (
    BatchProcessor,
    EventType,
    process_partial_response,
)
from aws_lambda_powertools.utilities.data_classes.dynamo_db_stream_event import (
    DynamoDBRecord,
    DynamoDBRecordEventName
)

processor = BatchProcessor(event_type=EventType.DynamoDBStreams)
logger = Logger(service="OrdersBackend")
tracer = Tracer(service="OrdersBackend")
metrics = Metrics(namespace="OrdersBackend", service="OrdersBackend")

stepfunctions = boto3.client('stepfunctions')

@tracer.capture_method
def record_handler(record: DynamoDBRecord):
    if record.dynamodb and record.dynamodb.new_image:
        logger.info(f"record={record}")
        
        if record.event_name == DynamoDBRecordEventName.INSERT:
            logger.info(f"Processing new order: {record.dynamodb.new_image}")
            process_new_order(record.dynamodb.new_image)
        elif record.event_name == DynamoDBRecordEventName.MODIFY:
            logger.info(f"Processing updated order: {record.dynamodb.new_image}")
            process_updated_order(record.dynamodb.new_image, record.dynamodb.old_image)
        elif record.event_name == DynamoDBRecordEventName.REMOVE:
            logger.info(f"Processing deleted order: {record.dynamodb.old_image}")
            process_deleted_order(record.dynamodb.old_image)
                
        message = record.dynamodb.new_image.get("Message")
        if message:
            logger.info(f"next message={message}")
            
            
@tracer.capture_lambda_handler
@logger.inject_lambda_context(log_event=True)
@metrics.log_metrics(capture_cold_start_metric=True)
def lambda_handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    try:
        process_partial_response(event=event, record_handler=record_handler, processor=processor, context=context)
        return {"statusCode": 200, "body": json.dumps({"message": "Stream processing completed successfully"})}
    
    except Exception as e:
        logger.exception("Error processing DynamoDB stream")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

def process_new_order(new_image: Dict[str, Any]) -> None:
    logger.info(f"Processing new order with new image: {new_image}")
    order_id = new_image.get("orderId", {})
    status = new_image.get("status", {})
    
    if status == "PENDING":
        try:
            execution_id = stepfunctions.start_execution(
                stateMachineArn=os.environ['STATE_MACHINE_ARN'],
                input=json.dumps(
                    {
                        "orderId": order_id,
                        "orderType": new_image.get("orderType", {}),
                        "ordersTableName": os.environ['ORDERS_TABLE'],
                        "customer": new_image.get("customer", {})
                     }                     
                )
            )
            logger.info(f"Started state machine execution for order={order_id}, execution_id={execution_id}")
        except Exception as e:
            logger.error(f"Failed to start state machine for order {order_id}: {str(e)}")

def process_updated_order(new_image: Dict[str, Any], old_image: Dict[str, Any]) -> None:
    new_status = new_image.get("status", {})
    old_status = old_image.get("status", {})
    
    if new_status != old_status:
        order_id = new_image.get("orderId", {})
        logger.info(f"Order {order_id} status changed from {old_status} to {new_status}")
        # Add any additional logic for status changes here

def process_deleted_order(old_image: Dict[str, Any]) -> None:
    order_id = old_image.get("orderId", {})
    logger.info(f"Order {order_id} was deleted")
    # Add any cleanup logic for deleted orders here
