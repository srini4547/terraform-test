import boto3

client = boto3.client('sns')

def lambda_handler(event, context):
    response = client.publish(
    TopicArn='arn:aws:sns:us-east-1:564154751867:hi',
    Message='Hey Your Jekins slave instance in is stopped now ,please take necessary action on the same ')
