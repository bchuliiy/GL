provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
}

data "aws_ami" "latest_windows_server_2019" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

resource "aws_instance" "windows_server_2019" {
  ami           = data.aws_ami.latest_windows_server_2019.id
  instance_type = "t2.micro"
  availability_zone = "eu-central-1b"
  vpc_security_group_ids = [aws_security_group.for_my_web_servers.id]

  count = 2
  tags = {
    Name = "IIS_web_server"
    owner = "Bodya"
    state = "prod"
  }
}

resource "aws_security_group" "for_my_web_servers" {
  name        = "WebServer Security Group"
  description = "My first Security Group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "my-nlb"

  load_balancer_type = "network"

  vpc_id  = "vpc-7fac1715"
  subnets = ["subnet-d0c5699c", "subnet-28954c54", "subnet-60ccaf0a"]


  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]


  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}