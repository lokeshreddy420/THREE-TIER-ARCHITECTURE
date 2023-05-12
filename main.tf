resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "web" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "app" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "db" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_nat_gateway" "example" {
  vpc_id = aws_vpc.example.id
  subnet_id = aws_subnet.app.id
}

resource "aws_elb" "example" {
  name = "example-elb"
  subnets = [
    aws_subnet.web.id,
    aws_subnet.web.id,
  ]
  security_groups = [
    aws_security_group.web.id,
  ]
}

resource "aws_autoscaling_group" "example" {
  name = "example-asg"
  desired_capacity = 2
  min_size = 1
  max_size = 3
  vpc_id = aws_vpc.example.id
  launch_configuration = aws_launch_configuration.example.id
  health_check_grace_period = 300
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-0123456789abcdef"
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.web.id,
  ]
}

resource "aws_rds_instance" "example" {
  instance_class = "db.t2.micro"
  engine = "mysql"
  username = "root"
  password = "password"
  database_name = "example"
}

resource "aws_security_group" "web" {
  name = "example-web-sg"
  ingress {
    protocol = "tcp"
    port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name = "example-db-sg"
  ingress {
    protocol = "tcp"
    port = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }
}
