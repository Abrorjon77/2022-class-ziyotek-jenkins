resource "aws_s3_bucket" "dev_bucket" {
  bucket = "jenkins-bucket-ziyotek-data.aws_caller_identity.current.account_id"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "*"
        }
    ]
}
EOF

 index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}


 
resource "aws_s3_bucket_object" "dev" {
  key          = "index.html"
  bucket       = aws_s3_bucket.dev_bucket.id
  content      = file("../assets/index.html")
  content_type = "text/html"

}
