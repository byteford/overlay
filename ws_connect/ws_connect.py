import json
import boto3
import os
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

xray_recorder.configure(service='Overlay')
plugins = ()
xray_recorder.configure(plugins=plugins)
patch_all()


def lambda_handler(event, context):
    print(event)
    return {
        'statusCode': 200,
        "headers": {
          'Content-Type': 'text/json',
        }
    }