from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import requests
import boto3
ses_client = boto3.client('ses')

def lambda_handler(event,context):
    lat = 37.774929
    lon = -122.419418
    api_key = '9abb36fd039d8d2582c3972e6b306a63'

    url = f'''https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={api_key}&units=imperial'''
    data = requests.get(url).json()
    temp = data.get('main',{}).get('temp','unknown')
    feels_like = data.get('main',{}).get('feels_like','unknown')
    wind_speed = data.get('wind',{}).get('speed','unknown')
    desc = data.get('weather',[{'desc':'unknown'}])[0].get('description')
    to_email = f'''The temperature in San Francisco is {temp} and feels like {feels_like} with wind speeds of {wind_speed}.\nThere are {desc}.'''.title()

    msg = MIMEMultipart()
    msg['Subject'] = 'San Francisco Weather'
    msg['From'] = 'Weather Service <dylanjfine@gmail.com>'
    msg['To'] = 'dylanjfine@gmail.com'
    body = to_email


    part = MIMEText(body)
    msg.attach(part)
    notification = {"RawMessage" : {"Data": msg.as_string()}}

    ses_client.send_raw_email(**notification)
    print("SUCCESS!")










































lambda_handler