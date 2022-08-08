import json
import boto3
import os
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

xray_recorder.configure(service='Overlay')
plugins = ()
xray_recorder.configure(plugins=plugins)
patch_all()
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
