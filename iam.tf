
# This data source gets the current AWS account ID, which we need for building specific ARNs.
data "aws_caller_identity" "current" {}

# This block FINDS the main Lambda role that the instructor already created.
data "aws_iam_role" "web_lambda_exec_role" {
  name = "${var.iam_role_name}-web_lambda_exec_role"
}

# This block FINDS the authorizer Lambda role that the instructor already created.
data "aws_iam_role" "pat_auth_lambda_exec_role" {
  name = "${var.iam_role_name}-pat-auth-lambda-execution-role"
}
