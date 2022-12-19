data "aws_ami" "example" {
  most_recent = true
  owners      = ["816725581106"]

  filter {
    name   = "name"
    values = ["amazon/amzn2-ami-hvm-2.0.20211001.1-x86_64-gp2"]
  }
}


data "aws_region" "current" {}

output "image_id" {
  value = data.aws_ami.example.image_id
}

data "aws_caller_identity" "current" {}
