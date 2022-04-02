import boto3
from urllib.parse import quote
client = boto3.client('dynamodb')

def get_res_item(res, item):
    return quote(res['Item'][item]['S'])
    
def lambda_handler(event, context):
    if "queryStringParameters" not in event:
        print("please pass in 'name', 'role' and 'social'")
        return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": "please pass in 'name', 'role' and 'social'"
    }
    
    overlay = event["queryStringParameters"]["overlay"]
    
    res = client.get_item(TableName="lowerthird", Key={"Index": {'S': overlay}})


    user = "name=" +get_res_item(res,'FullName') +"&role="+ get_res_item(res,"Role")+"&social=" + get_res_item(res,'Social')
    
    return {
        'statusCode': 200,
        "headers": {
          'Content-Type': 'text/html',
        },
        'body': """
        <html style="height:1080; width:1920">
            <Body>
                <div class=LowerThird style="top:70%; left:0%; position:absolute">
                    <img src="https://b6pgciri1i.execute-api.eu-west-2.amazonaws.com/default/lower?{user}" alt="" width=40%>
                </div>
            </Body>
        </html>
        """.format(user=user )
    }
