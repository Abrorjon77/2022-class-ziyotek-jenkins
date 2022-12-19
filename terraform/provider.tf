provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      owner = "Abrorjon"
    }
  }
}

# terraform {
#   backend "s3" {
#     bucket = "public-tfpstate-rady-bucket"
#     key    = "tfstate"
#     region = "us-east-1"
#   }
# }
