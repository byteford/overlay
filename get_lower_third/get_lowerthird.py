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
    Index = event["queryStringParameters"]["Index"]
    
    #Get table name from envvars
    TableName = os.environ["lowerthird_table"] if "overlay_table" in os.environ else "lowerthird"
    
    table = dynamodb.Table(TableName)
    
    responce = table.get_item(Key={'Index': Index})
    
    print(responce['Item']['Text'])
    return {
        'statusCode': 200,
        "headers": {
          'Content-Type': 'text/json',
          'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(responce['Item']['Text'])
    }