data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

# The main Lambda function.
resource "aws_lambda_function" "web_lambda" {
  function_name = "${var.iam_role_name}_get_file_web_lambda"
  role          = data.aws_iam_role.web_lambda_exec_role.arn
  handler       = "index.return_image_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# The Lambda Authorizer function (no changes needed).
resource "aws_lambda_function" "pat_auth_lambda" {
  function_name    = "${var.iam_role_name}_pat_auth_lambda"
  role             = data.aws_iam_role.pat_auth_lambda_exec_role.arn
  handler          = "index.auth_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      EXPECTED_PAT = var.static_token
    }
  }
}
