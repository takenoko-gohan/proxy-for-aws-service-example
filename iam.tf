resource "aws_iam_role" "api_gateway_role" {
  name = "proxy-test-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3" {
  name = "s3-proxy-test-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.proxy_test.arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "sqs" {
  name = "sqs-proxy-test-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ],
        Resource = aws_sqs_queue.proxy_test.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_role_01" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_role_policy_attachment" "api_gateway_role_02" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.sqs.arn
}
