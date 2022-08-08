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
    
    #Get table name from envvars
    TableName = os.environ["table"] if "table" in os.environ else "current_overlay"
    
    table = dynamodb.Table(TableName)
    
    responce = table.get_item(Key={'Index': "0"})
    
    
    return {
        'statusCode': 200,
        "headers": {
          'Content-Type': 'text/json',
        },
        'body': json.dumps(responce['Item']['Value'])
    }
