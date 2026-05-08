resource "aws_s3_bucket" "dev_bucket" {
  bucket        = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "dev_bucket" {
  bucket = aws_s3_bucket.dev_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource  = ["arn:aws:s3:::${aws_s3_bucket.dev_bucket.id}/*"]
    }]
  })
}

resource "aws_s3_bucket_website_configuration" "dev_bucket" {
  bucket = aws_s3_bucket.dev_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "dev" {
  bucket       = aws_s3_bucket.dev_bucket.id
  key          = "index.html"
  content      = file("../assets/index.html")
  content_type = "text/html"
}