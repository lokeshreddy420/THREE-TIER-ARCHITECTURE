provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "main" {
  vpc_id = aws_vpc.main.id
  subnet_id = aws_subnet.private.id
}

resource "aws_load_balancer" "main" {
  name = "my-load-balancer"
  
  # The subnets that the load balancer will be attached to.
  subnets = [
    aws_subnet.public.id,
    aws_subnet.public.id,
  ]

  # The type of load balancer.
  type = "application"

  # The health check settings for the load balancer.
  health_check {
    interval = 30
    timeout = 5
    unhealthy_threshold = 2
    healthy_threshold = 2
  }
}

resource "aws_rds_instance" "main" {
  name = "my-database"
  engine = "mysql"
  instance_class = "db.t2.micro"
  
  # The VPC that the database instance will be created in.
  vpc_id = aws_vpc.main.id

  # The subnet that the database instance will be created in.
  subnet_id = aws_subnet.private.id

  # The database credentials.
  username = "root"
  password = "my-password"
}

resource "aws_ec2_instance" "web" {
  name = "my-web-server"
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  
  # The VPC that the instance will be created in.
  vpc_id = aws_vpc.main.id

  # The subnet that the instance will be created in.
  subnet_id = aws_subnet.public.id

  # The security groups that the instance will be associated with.
  security_groups = [
    aws_security_group.web.id,
  ]
}

resource "aws_security_group" "web" {
  name = "my-web-security-group"
  
  # The inbound rules for the security group.
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
