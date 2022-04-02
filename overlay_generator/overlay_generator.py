import boto3
from urllib.parse import quote
import os
client = boto3.client('dynamodb')

def get_res_item(res, item):
    print(res['Item'][item])
    return quote(res['Item'][item]['S'])

def get_lowerthird(number, style):
    TableName = os.environ["lowerthird_table"]
    res = client.get_item(TableName=TableName, Key={"Index": {'S': number}})

    user = "name=" +get_res_item(res,'FullName') +"&role="+ get_res_item(res,"Role")+"&social=" + get_res_item(res,'Social')
    
    url = os.environ["image_src_url"]
    return """
    <div class=LowerThird style="{style}">
            <img src="{url}?{user}" alt="" width=100%>
        </div>
    """.format(style=style,url=url,user=user )
    
def get_overlay(overlay):
    print(overlay['M'])
    if "Lowerthird" in overlay['M']:
        return get_lowerthird(overlay['M']['Lowerthird']['S'],overlay['M']['Style']['S'])
    return ""

def get_body(overlay):
    TableName = os.environ["overlay_table"]
    res = client.get_item(TableName=TableName, Key={"Index": {'S': overlay}})
    print(res['Item']['Overlay']['M'].keys())
    
    overlaybuit = ""
    
    for key in res['Item']['Overlay']['M'].keys():
    
        overlaybuit = overlaybuit + get_overlay(res['Item']['Overlay']['M'][key])
    
    return """
    <div class=Overlay>
        {overlay}
    </div>
            """.format(overlay=overlaybuit)

def lambda_handler(event, context):
    if "queryStringParameters" not in event:
        print("please pass in an overlaynumber")
        return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": "please pass in an overlaynumber"
    }
    
    overlay = event["queryStringParameters"]["overlay"]
    

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
