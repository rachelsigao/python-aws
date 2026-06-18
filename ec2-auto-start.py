import boto3
from botocore.exceptions import ClientError


def start_instances_by_tag(tags, region):
    # Create an EC2 client for the given AWS region
    ec2 = boto3.client('ec2', region_name=region)

    # Build filters from tags (example: AutoStartStop=True, Environment=Dev)
    tag_filters = [{'Name': f'tag:{key}', 'Values': [value]} for key, value in tags.items()]

    # Only include instances that are currently stopped
    tag_filters.append({'Name': 'instance-state-name', 'Values': ['stopped']})

    try:
        # Use paginator so code works even if there are many EC2 instances
        paginator = ec2.get_paginator('describe_instances')
        page_iterator = paginator.paginate(Filters=tag_filters)

        # Collect matching instance IDs
        instances = []
        for page in page_iterator:
            for reservation in page['Reservations']:
                for instance in reservation['Instances']:
                    instances.append(instance['InstanceId'])

        # Start instances if any were found
        if instances:
            start_response = ec2.start_instances(InstanceIds=instances)
            print(f'Started instances: {instances}')
            return start_response
        else:
            print('No stopped instances found with the specified tags.')

    # Handle AWS API errors gracefully
    except ClientError as e:
        print(f'An error occurred: {e}')


def lambda_handler(event, context):
    # Tags used to find instances to start
    tags = {
        'AutoStartStop': 'True',
        'Environment': 'Dev'
    }

    # AWS region where instances are located
    region = 'us-east-1'

    # Run the start logic
    start_instances_by_tag(tags, region)