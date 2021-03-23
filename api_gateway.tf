resource "aws_api_gateway_rest_api" "proxy_test" {
  name = "proxy-test-api"

  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

resource "aws_api_gateway_deployment" "proxy_test" {
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.proxy_test.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.s3_get,
    aws_api_gateway_method.s3_put,
  ]
}

resource "aws_api_gateway_stage" "proxy_test" {
  deployment_id = aws_api_gateway_deployment.proxy_test.id
  rest_api_id   = aws_api_gateway_rest_api.proxy_test.id
  stage_name    = "v1"
}

/*
S3 リソース・メソッド
*/
resource "aws_api_gateway_resource" "s3" {
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
  parent_id   = aws_api_gateway_rest_api.proxy_test.root_resource_id
  path_part   = "s3"
}

resource "aws_api_gateway_resource" "object" {
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
  parent_id   = aws_api_gateway_resource.s3.id
  path_part   = "{s3_object}"
}

resource "aws_api_gateway_method" "s3_get" {
  api_key_required = false
  authorization    = "NONE"
  http_method      = "GET"
  request_parameters = {
    "method.request.path.s3_object" = true
  }
  resource_id = aws_api_gateway_resource.object.id
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
}

resource "aws_api_gateway_method_response" "s3_get_200" {
  http_method = aws_api_gateway_method.s3_get.http_method
  resource_id = aws_api_gateway_resource.object.id
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
  response_models = {
    "application/json" = "Empty"
  }
  status_code = "200"
}

resource "aws_api_gateway_integration" "s3_get" {
  connection_type         = "INTERNET"
  credentials             = aws_iam_role.api_gateway_role.arn
  http_method             = aws_api_gateway_method.s3_get.http_method
  integration_http_method = "GET"
  request_parameters = {
    "integration.request.path.s3_object" = "method.request.path.s3_object"
  }
  resource_id          = aws_api_gateway_resource.object.id
  rest_api_id          = aws_api_gateway_rest_api.proxy_test.id
  timeout_milliseconds = 29000
  type                 = "AWS"
  uri                  = "arn:aws:apigateway:ap-northeast-1:s3:path/${aws_s3_bucket.proxy_test.bucket}/{s3_object}"
}

resource "aws_api_gateway_integration_response" "s3_get_200" {
  http_method = aws_api_gateway_method.s3_get.http_method
  resource_id = aws_api_gateway_resource.object.id
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
  response_templates = {
    "application/json" = ""
  }
  status_code = aws_api_gateway_method_response.s3_get_200.status_code
}

resource "aws_api_gateway_method" "s3_put" {
  api_key_required = false
  authorization    = "NONE"
  http_method      = "PUT"
  request_parameters = {
    "method.request.path.s3_object" = true
  }
  resource_id = aws_api_gateway_resource.object.id
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
}

resource "aws_api_gateway_method_response" "s3_put_200" {
  http_method = aws_api_gateway_method.s3_put.http_method
  resource_id = aws_api_gateway_resource.object.id
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
  response_models = {
    "application/json" = "Empty"
  }
  status_code = "200"
}

resource "aws_api_gateway_integration" "s3_put" {
  connection_type         = "INTERNET"
  credentials             = aws_iam_role.api_gateway_role.arn
  http_method             = aws_api_gateway_method.s3_put.http_method
  integration_http_method = "PUT"
  request_parameters = {
    "integration.request.path.s3_object" = "method.request.path.s3_object"
  }
  resource_id          = aws_api_gateway_resource.object.id
  rest_api_id          = aws_api_gateway_rest_api.proxy_test.id
  timeout_milliseconds = 29000
  type                 = "AWS"
  uri                  = "arn:aws:apigateway:ap-northeast-1:s3:path/${aws_s3_bucket.proxy_test.bucket}/{s3_object}"
}

resource "aws_api_gateway_integration_response" "s3_put_200" {
  http_method = aws_api_gateway_method.s3_put.http_method
  resource_id = aws_api_gateway_resource.object.id
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
  response_templates = {
    "application/json" = ""
  }
  status_code = aws_api_gateway_method_response.s3_put_200.status_code
}

/*
SQS リソース・メソッド
*/
resource "aws_api_gateway_resource" "sqs" {
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
  parent_id   = aws_api_gateway_rest_api.proxy_test.root_resource_id
  path_part   = "sqs"
}

resource "aws_api_gateway_method" "sqs_get" {
  api_key_required = false
  authorization    = "NONE"
  http_method      = "GET"
  resource_id      = aws_api_gateway_resource.sqs.id
  rest_api_id      = aws_api_gateway_rest_api.proxy_test.id
}

resource "aws_api_gateway_method_response" "sqs_get_200" {
  http_method = aws_api_gateway_method.sqs_get.http_method
  resource_id = aws_api_gateway_resource.sqs.id
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
  response_models = {
    "application/json" = "Empty"
  }
  status_code = "200"
}

resource "aws_api_gateway_integration" "sqs_get" {
  connection_type         = "INTERNET"
  credentials             = aws_iam_role.api_gateway_role.arn
  http_method             = aws_api_gateway_method.sqs_get.http_method
  integration_http_method = "GET"
  resource_id             = aws_api_gateway_resource.sqs.id
  rest_api_id             = aws_api_gateway_rest_api.proxy_test.id
  timeout_milliseconds    = 29000
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:ap-northeast-1:sqs:path/${var.account_id}/${aws_sqs_queue.proxy_test.name}"
}

resource "aws_api_gateway_integration_response" "sqs_get_200" {
  http_method = aws_api_gateway_method.sqs_get.http_method
  resource_id = aws_api_gateway_resource.sqs.id
  rest_api_id = aws_api_gateway_rest_api.proxy_test.id
  response_templates = {
    "application/json" = ""
  }
  status_code = aws_api_gateway_method_response.sqs_get_200.status_code
}
