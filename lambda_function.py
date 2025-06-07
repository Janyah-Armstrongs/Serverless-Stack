import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Api-Items-Table')  # Use your table name exactly

def lambda_handler(event, context):
    try:
        # Parse the JSON body from API Gateway event
        body = json.loads(event['body'])
        
        # Extract id and name from the request body
        item_id = body['id']
        item_name = body['name']
        
        # Put the item into DynamoDB
        table.put_item(Item={
            'id': item_id,
            'name': item_name
        })
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Item added successfully!'})
        }
    except Exception as e:
        # Return error message if something goes wrong
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
