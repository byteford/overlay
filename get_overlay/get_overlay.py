import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')


def lambda_handler(event, context):
    overlay = event["queryStringParameters"]["overlay"]
    
    #Get table name from envvars
    TableName = os.environ["overlay_table"] if "overlay_table" in os.environ else "overlay"
    
    table = dynamodb.Table(TableName)
    
    responce = table.get_item(Key={'Index': overlay})
    
    
    return {
        'statusCode': 200,
        "headers": {
          'Content-Type': 'text/json',
        },
        'body': json.dumps(responce['Item']['Overlay'])
    }
