import boto3
from urllib.parse import quote
import os
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

xray_recorder.configure(service='Overlay')
plugins = ('EC2Plugin')
xray_recorder.configure(plugins=plugins)
patch_all()
client = boto3.client('dynamodb')
dynamodb = boto3.resource('dynamodb')

def get_lowerthird_config(table):
    #loop though all the configs
    config = table["config"]
    output = ""
    for key in config.keys():
        print(config[key])
        outputItem = "{key}_size={size}&{key}_loc_x={x}&{key}_loc_y={y}".format(key=key.lower(), size=config[key]["Font_size"], x=config[key]["X"],y=config[key]["Y"])
        output = output + "&" + outputItem
    return output
    
def get_lowerthird(number, style, config):
    TableName = os.environ["lowerthird_table"]
    table = dynamodb.Table(TableName)
    
    responce = table.get_item(Key={'Index': number})
    text = responce['Item']['Text']
    print(text)
    print(text.keys())
    textout = ""
    for key in text.keys():
        textout = textout + "&"+key.lower() + "=" + quote(text[key])
    #user = "name=" +quote(text['FullName']) +"&role="+ quote(text['Role'])+"&social=" + quote(text['Social'])

    
    url = os.environ["image_src_url"]
    return """
    <div class=LowerThird style="{style}">
            <img src="{url}?{user}&{config}" alt="" width=100%>
        </div>
    """.format(style=style,url=url,user=textout, config=config )
    
def get_overlay(overlay):
    #If the overlayobject is lowerthird then return a lowerthird object
    if "Lowerthird" in overlay:
        return get_lowerthird(overlay['Lowerthird'],overlay['Style'],get_lowerthird_config(overlay))
    return ""

def get_body(overlay):
    #Get table name from envvars
    TableName = os.environ["overlay_table"]
    
    table = dynamodb.Table(TableName)
    
    responce = table.get_item(Key={'Index': overlay})
    print(responce)
    #Loop though all the overlay object in the table and build an html object to return
    overlaybuit = ""
    for key in responce['Item']['Overlay'].keys():
    
        overlaybuit = overlaybuit + get_overlay(responce['Item']['Overlay'][key])
    
    return """
        <div class=Overlay>
            {overlay}
        </div>
            """.format(overlay=overlaybuit)

def lambda_handler(event, context):
    #if no url params return
    if "queryStringParameters" not in event:
        return {
        "statusCode": 500,
        "body": "please pass in an overlaynumber"
    }
    #Get the overlay number for the params
    overlay = event["queryStringParameters"]["overlay"]
    
    #Get the body and add it in to the html to return
    return {
        'statusCode': 200,
        "headers": {
          'Content-Type': 'text/html',
        },
        'body': """
        <html style="height:1080; width:1920">
            <Body>
                {body}
            </Body>
        </html>
        """.format(body=get_body(overlay))
    }
