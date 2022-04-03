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
    name_size = int(params["name_size"] if "name_size" in params else 10) 
    print(name_size)
    role_size = int(params["role_size"] if "role_size" in params else 10) 
    print(role_size)
    social_size = int(params["social_size"] if "social_size" in params else 10) 
    print(social_size)

    name_loc_x = int(params["name_loc_x"] if "name_loc_x" in params else 10) 
    print(name_loc_x)
    name_loc_y = int(params["name_loc_y"] if "name_loc_y" in params else 10) 
    print(name_loc_y)
    role_loc_x = int(params["role_loc_x"] if "role_loc_x" in params else 10) 
    print(role_loc_x)
    role_loc_y = int(params["role_loc_y"] if "role_loc_y" in params else 10) 
    print(role_loc_y)
    social_loc_x = int(params["social_loc_x"] if "social_loc_x" in params else 10) 
    print(social_loc_x)
    social_loc_y = int(params["social_loc_y"] if "social_loc_y" in params else 10) 
    print(social_loc_y)

    img = Image.open(local_img)

    logging.info(img)

    image_editable = ImageDraw.Draw(img)


    addtext(image_editable, cords= (name_loc_x,name_loc_y),colour = (0,0,0),title_text=name,text_size=name_size)
    addtext(image_editable, cords= (role_loc_x,role_loc_y),colour = (0,0,0),title_text=role,text_size=role_size)
    addtext(image_editable, cords= (social_loc_x,social_loc_y),colour = (255,255,255),title_text=social,text_size=social_size)
    addtext(image_editable, cords= (700,100),colour = (0,0,0),title_text=name,text_size=name_size)
    addtext(image_editable, cords= (700,370),colour = (0,0,0),title_text=role,text_size=role_size)
    addtext(image_editable, cords= (650,480),colour = (255,255,255),title_text=social,text_size=social_size)

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
