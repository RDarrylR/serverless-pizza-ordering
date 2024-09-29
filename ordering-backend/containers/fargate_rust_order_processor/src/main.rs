use aws_config::meta::region::RegionProviderChain;
use aws_config::BehaviorVersion;
use aws_sdk_dynamodb::Client as DynamoDB_Client;
use aws_sdk_dynamodb::types::AttributeValue;
use aws_sdk_dynamodb::types::ReturnValue;
use aws_sdk_sfn as sfn;
use rand::Rng;
use serde_json::json;
use std::env;
use std::error::Error;
use std::fs::File;
use std::io::Write;
use std::path::Path;
use std::thread;
use std::time::Duration;
use std::time::Instant;


#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    // Need these key values to know what to process and how to send status
    let TASK_TOKEN = env::var("TASK_TOKEN").unwrap_or(String::from(""));
    let ORDERS_TABLE_NAME = env::var("ORDERS_TABLE_NAME").expect("No orders table name was set");
    let ORDER_ID = env::var("ORDER_ID").expect("No orderId was set");
    let ORDER_TYPE = env::var("ORDER_TYPE").expect("No order type was set");

    // Want to keep track of processing time
    let run_time = Instant::now();

    // Setup AWS credentials
    let region_provider = RegionProviderChain::default_provider().or_else("us-east-1");
    let config = aws_config::defaults(BehaviorVersion::latest())
        .profile_name("blog-admin")
        .region(region_provider)
        .load()
        .await;

    let ddb_client = DynamoDB_Client::new(&config);

    // Get the current order to process
    let results = ddb_client
        .query()
        .table_name(ORDERS_TABLE_NAME.clone())
        .key_condition_expression("#orderId = :orderId")
        .expression_attribute_names("#orderId", "orderId")
        .expression_attribute_values(":orderId", AttributeValue::S(ORDER_ID.clone()))
        .send()
        .await?;

    println!("results={:?}", results);

    println!("Updating status to STARTED");
    // Upate the order status to STARTED
    let order_status = AttributeValue::S(String::from("STARTED")); 
    let order_id = AttributeValue::S(String::from(ORDER_ID.clone()));  

    let update_expression = String::from("SET #st = :st");

    let request = ddb_client
        .update_item()
        .table_name(ORDERS_TABLE_NAME.clone())
        .key("orderId", order_id.clone())
        .update_expression(update_expression.clone())
        .expression_attribute_values(String::from(":st"), order_status)
        .expression_attribute_names(String::from("#st"), "status")
        .return_values(ReturnValue::AllNew);
    let resp = request.send().await?;

    println!("Before cooking the items in the order");

    // This is where we are actually cooking the items in the order
    let num = rand::thread_rng().gen_range(4..50);
    thread::sleep(Duration::from_secs(num));

    println!("After cooking the items in the order");
 
    let mut order_status = AttributeValue::S(String::from("COOKED"));  
    if ORDER_TYPE.eq("delivery") {
        order_status = AttributeValue::S(String::from("READY_FOR_DELIVERY"));
        println!("Updating status to READY_FOR_DELIVERY");
    } else {
        order_status = AttributeValue::S(String::from("READY_FOR_PICKUP"));
        println!("Updating status to READY_FOR_PICKUP");
    }

    let request = ddb_client
        .update_item()
        .table_name(ORDERS_TABLE_NAME.clone())
        .key("orderId", order_id.clone())
        .update_expression(update_expression.clone())
        .expression_attribute_values(String::from(":st"), order_status)
        .expression_attribute_names(String::from("#st"), "status")
        .return_values(ReturnValue::AllNew);
    let resp = request.send().await?;    

    if TASK_TOKEN.is_empty() {
        println!("No task token found, skipping sending status");
    } else {
        let sfn_client = sfn::Client::new(&config);

        let response = json!({
            "status": "Success",
            "processing_time": format!("{} seconds", run_time.elapsed().as_secs()),
        });
        let success_result = sfn_client
            .send_task_success()
            .task_token(TASK_TOKEN.clone())
            .output(response.to_string())
            .send()
            .await;

        match success_result {
            Ok(_) => {
                println!("Sucessfully updated task status.")
            }
            Err(e) => println!("Error updating task status error: {e:?}"),
        }
    }

    Ok(())
}
