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
    bucket = "YOUR_TERRAFORM_STATE_BUCKET"  # TODO: replace with your S3 bucket name
    key    = "tfstate"
    region = "us-east-1"
  }
}
