import boto3
import json

def lambda_handler(event, context):
    # Initialize a CodePipeline client
    codepipeline = boto3.client('codepipeline')

    try:
        cloudfront_client = boto3.client('cloudfront')

        # Replace 'YourDistributionID' with your actual CloudFront distribution ID
        distribution_id = 'E33JRMUO5XD2GS'

        # Create an invalidation request for the entire distribution
        invalidation_response = cloudfront_client.create_invalidation(
            DistributionId=distribution_id,
            InvalidationBatch={
                'Paths': {
                    'Quantity': 1,
                    'Items': ['/*']  # Invalidate all objects
                },
                'CallerReference': 'codepipeline-invalidation'
            }
        )

        # Report success to CodePipeline
        codepipeline.put_job_success_result(
            jobId=event['CodePipeline.job']['id']
            print("success")
        )

    except Exception as e:
        # Report failure to CodePipeline
        codepipeline.put_job_failure_result(
            jobId=event['CodePipeline.job']['id'],
            failureDetails={
                'type': 'JobFailed',
                'message': str(e)
                print("fail")
            }
        )

    return {
        'statusCode': 200,
        'body': 'Lambda function executed successfully.'
    }