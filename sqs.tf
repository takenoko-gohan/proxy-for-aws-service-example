resource "aws_sqs_queue" "proxy_test" {
  name                        = "proxy-test-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}
