# main.tf

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      TerraformManagedBy = var.iam_role_name
    }
  }
}

#provider "aws" {
 # region = "eu-central-1"
 # alias  = "no-default-tags"
#}

resource "aws_s3_bucket" "web_bucket" {
  bucket = "webapp-bucket-${replace(lower(var.iam_role_name), "studentrole-", "")}"
 # provider = aws.no-default-tags

}

resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowLambdaReadAccess",
      Effect    = "Allow",
      Principal = {
        AWS = data.aws_iam_role.web_lambda_exec_role.arn
      },
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.web_bucket.arn}/*"
    }]
  })
}


resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/api-gateway/${aws_apigatewayv2_api.http_api.name}"
  retention_in_days = 7
  depends_on = [aws_apigatewayv2_api.http_api]
}

resource "aws_s3_object" "fruit_salad_image" {
  bucket = aws_s3_bucket.web_bucket.id
  key    = "fruitsalad.png"
  source = "image/fruitsalad.png"
}
