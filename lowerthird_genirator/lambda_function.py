from PIL import Image, ImageFont, ImageDraw
import logging
import os
import base64
from io import BytesIO
import boto3
logging.basicConfig(level=logging.DEBUG)
logging.info("starting")

s3 = boto3.resource('s3')
local_img = "/tmp/image.png"
local_font = "/tmp/font.ttf"


def addtext(img, cords, colour,title_text, text_size):
    title_font = ImageFont.truetype(local_font,text_size)
    img.text(cords, title_text,colour, font=title_font)

def download_from_s3():
    image_bucket = os.environ.get("image_bucket")
    image_key = os.environ.get("image_key")
    print(image_bucket,image_key)
    s3.Bucket(image_bucket).download_file(image_key, local_img)

    font_bucket = os.environ.get("font_bucket")
    font_key = os.environ.get("font_key")
    print(font_bucket,font_key)
    s3.Bucket(font_bucket).download_file(font_key, local_font)

def buildImage(params):
    name = str(params["name"] if "name" in params else " ") 
    print(name)
    role = str(params["role"] if "role" in params else " ") 
    print(role)
    social = str(params["social"] if "social" in params else " ") 
    print(social)
    img = Image.open(local_img)

    logging.info(img)

    image_editable = ImageDraw.Draw(img)

    addtext(image_editable, cords= (700,100),colour = (0,0,0),title_text=name,text_size=190)
    addtext(image_editable, cords= (700,370),colour = (0,0,0),title_text=role,text_size=100)
    addtext(image_editable, cords= (650,480),colour = (255,255,255),title_text=social,text_size=70)
    return img
    
    

def lambda_handler(event,context):
    download_from_s3()
    print(event)
    if "queryStringParameters" not in event:
        print("please pass in 'name', 'role' and 'social'")
        return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": "please pass in 'name', 'role' and 'social'"
    }

    img = buildImage(event["queryStringParameters"])

    bufferd = BytesIO()
    img.save(bufferd, format="png")
    img_str = base64.b64encode(bufferd.getvalue())
    return {
        "isBase64Encoded": True,
        "statusCode": 200,
        "headers": {
            "Content-type": "image/png"
        },
        "body": img_str
    }
