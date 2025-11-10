output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.web_bucket.bucket
}
