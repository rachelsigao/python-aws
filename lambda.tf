# Archive the EC2 Auto Start Python script into a ZIP file for AWS Lambda deployment
data "archive_file" "ec2_auto_start_zip" {
  type        = "zip"
  source_file = "${path.module}/ec2-auto-start.py"  # Source: the Python script
  output_path = "${path.module}/ec2-auto-start.zip"  # Output: the ZIP file
}

# Archive the EC2 Auto Stop Python script into a ZIP file for AWS Lambda deployment
data "archive_file" "ec2_auto_stop_zip" {
  type        = "zip"
  source_file = "${path.module}/ec2-auto-stop.py"  # Source: the Python script
  output_path = "${path.module}/ec2-auto-stop.zip"  # Output: the ZIP file
}

# Lambda function to start EC2 instances based on tags
resource "aws_lambda_function" "ec2_auto_start" {
  function_name = "EC2AutoStart"  # Name of the Lambda function in AWS
  handler       = "ec2-auto-start.lambda_handler"  # Entry point: file.function_name
  role          = aws_iam_role.lambda_role.arn  # IAM role with permissions to start EC2 instances
  runtime       = "python3.12"  # Python version to use

  filename         = data.archive_file.ec2_auto_start_zip.output_path  # Zipped Python code
  source_code_hash = data.archive_file.ec2_auto_start_zip.output_base64sha256  # Hash for updates
  timeout          = 60  # Maximum execution time in seconds

  depends_on = [aws_iam_policy.lambda_policy]  # Ensure IAM policy exists first
}



# Lambda function to stop EC2 instances based on tags
resource "aws_lambda_function" "ec2_auto_stop" {
  function_name = "EC2AutoStop"  # Name of the Lambda function in AWS
  handler       = "ec2-auto-stop.lambda_handler"  # Entry point: file.function_name
  role          = aws_iam_role.lambda_role.arn  # IAM role with permissions to stop EC2 instances
  runtime       = "python3.12"  # Python version to use

  filename         = data.archive_file.ec2_auto_stop_zip.output_path  # Zipped Python code
  source_code_hash = data.archive_file.ec2_auto_stop_zip.output_base64sha256  # Hash for updates
  timeout          = 60  # Maximum execution time in seconds

  depends_on = [aws_iam_policy.lambda_policy]  # Ensure IAM policy exists first
}