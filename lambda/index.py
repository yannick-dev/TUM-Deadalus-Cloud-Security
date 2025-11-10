import json
import boto3
import os
import base64
from botocore.client import Config

s3_client = boto3.client('s3', region_name='eu-central-1', config=Config(signature_version='s3v4'))

# The authorizer handler is unchanged.
def auth_handler(event, context):
    
    # This is the V2.0 format. It defaults to 'Deny'.
    response = {
        "isAuthorized": False
    }

    try:
        auth_header = event['headers'].get('authorization', '')
        if auth_header.startswith("Bearer "):
            token = auth_header.split(" ")[1]
            expected_token = os.environ['EXPECTED_PAT']
            
            if token == expected_token:
                # If the token is valid, we change the response to 'Allow'.
                response = {
                    "isAuthorized": True
                }
                
    except Exception as e:
        print(f"Authentication error: {e}")
        # If any error happens, it just returns the default "isAuthorized": False

    return response

# --- THIS IS THE VULNERABLE "DIRECT DOWNLOAD" HANDLER ---
def return_image_handler(event, context):
    # This is the vulnerability: the bucket and file names are taken
    # directly from the user's request without validation.
    try:
        bucket_name = event['queryStringParameters']['bucket']
        object_key = event['queryStringParameters']['file']
    except (KeyError, TypeError):
        return {"statusCode": 400, "body": json.dumps({"error": "Bad Request: 'bucket' and 'file' query string parameters are required."})}
    
    try:
        # Download the object from S3 into the Lambda's memory.
        s3_object = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        
        # Read the binary content of the image.
        image_content = s3_object['Body'].read()
        
        # Return the image data directly, encoded in Base64.
        return {
            "statusCode": 200,
            "headers": { "Content-Type": "image/jpeg" }, # Or image/png
            "body": base64.b64encode(image_content).decode('utf-8'),
            "isBase64Encoded": True 
        }
    except Exception as e:
        print(f"Error getting object from S3: {e}")
        return {"statusCode": 404, "body": json.dumps({"error": f"Object '{object_key}' not found in bucket '{bucket_name}'."})}
