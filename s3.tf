resource "aws_s3_bucket" "proxy_test" {
  bucket = "${var.name}-proxy-test-bucket"
  acl    = "private"
}