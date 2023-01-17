data "aws_ami" "example" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*x86_64-gp2"]
  }
}

data "aws_region" "current" {}

output "image_id" {
  value = data.aws_ami.example.image_id
}

data "aws_caller_identity" "current" {}

