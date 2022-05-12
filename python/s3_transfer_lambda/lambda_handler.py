import boto3
s3client = boto3.client('s3')
copy_bucket = 'test-output-bucket-1000'
def lambda_handler(event,context):
    print(event)
    records = event['Records']
    for record in records:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        copy_source = {
        'Bucket': bucket,
        'Key': key
        }
        s3client.copy(copy_source,copy_bucket,key)
    