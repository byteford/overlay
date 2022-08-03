import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')


def lambda_handler(event, context):
    overlay = event["queryStringParameters"]["overlay"]
    
    #Get table name from envvars
    TableName = os.environ["table"] if "table" in os.environ else "current_overlay"
    
    table = dynamodb.Table(TableName)
    
    responce = table.put_item(Item={'Index': overlay, 'Value': overlay})
    
    
    return {
        'statusCode': 200,
        "headers": {
          'Content-Type': 'text/json',
        },
        'body': json.dumps(responce['Item']['Overlay'])
    }