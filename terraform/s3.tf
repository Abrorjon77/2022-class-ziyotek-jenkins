resource "aws_s3_bucket" "dev_bucket" {
  bucket = "jenkins-bucket-ziyotek-816725581106}"

}
resource "aws_s3_bucket_object" "dev_bucket" {
  key          = "index.html"
  bucket       = "aws_s3_bucket.dev_bucket.id"
  content      = file("../assets/index.html")
  content_type = "text/html"

}
