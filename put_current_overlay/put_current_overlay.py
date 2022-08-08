import json
import boto3
import os
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

xray_recorder.configure(service='Overlay')
plugins = ('EC2Plugin')
xray_recorder.configure(plugins=plugins)
patch_all()
dynamodb = boto3.resource('dynamodb')


def lambda_handler(event, context):
    overlay = event["queryStringParameters"]["overlay"]
    
    #Get table name from envvars
    TableName = os.environ["table"] if "table" in os.environ else "current_overlay"
    
    table = dynamodb.Table(TableName)
    
    responce = table.put_item(Item={'Index': str(0), 'Value': overlay})
    print(responce)
    
    return {
        'statusCode': 200
    }
