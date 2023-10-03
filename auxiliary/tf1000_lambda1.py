import boto3
import time
import os

def lambda_handler(event, context):
    # Initialize a CodePipeline client
    codepipeline = boto3.client('codepipeline')
    try:
        cloudfront_client = boto3.client('cloudfront')

        # get env var of CloudFront distribution ID
        distribution_id = os.environ['DISTRIBUTION']

        # Create an invalidation request for the entire distribution
        invalidation_response = cloudfront_client.create_invalidation(
            DistributionId=distribution_id,
            InvalidationBatch={
                'Paths': {
                    'Quantity': 1,
                    'Items': ['/*']  # Invalidate all objects
                },
                'CallerReference': str(time.time()) # aws require callerReference to be unique. I used a simple timestamp
            }
        )
        # Report success to CodePipeline
        codepipeline.put_job_success_result(
            jobId=event['CodePipeline.job']['id']
        )
        # print the invalidation response for debug
        print(invalidation_response)
        print("success")

    except Exception as e:
        # Report failure to CodePipeline
        codepipeline.put_job_failure_result(
            jobId=event['CodePipeline.job']['id'],
            failureDetails={
                'type': 'JobFailed',
                'message': str(e)
            }
        )
        # print error for debug
        print(str(e))
    return {
        'statusCode': 200,
        'body': 'Lambda function executed successfully.'
    }
