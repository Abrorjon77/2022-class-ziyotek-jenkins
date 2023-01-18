provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      owner = "Abrorjon"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "jenkins-bucket-ziyotek-816725581106"
    key    = "tfstate"
    region = "us-east-1"
  }
}
