# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main"
  }
}

# Create a public subnet for the presentation layer
resource "aws_subnet" "presentation_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Presentation Public"
  }
}

# Create a private subnet for the presentation layer
resource "aws_subnet" "presentation_private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Presentation Private"
  }
}

# Create a public subnet for the application layer
resource "aws_subnet" "application_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Application Public"
  }
}

# Create a private subnet for the application layer
resource "aws_subnet" "application_private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Application Private"
  }
}

# Create a private subnet for the database layer
resource "aws_subnet" "database" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Database"
  }
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main"
  }
}

# Create a Route Table for the VPC
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Main"
  }
}

# Associate the public subnets with the Route Table
resource "aws_route_table_association" "presentation_public" {
  subnet_id      = aws_subnet.presentation_public.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "application_public" {
  subnet_id      = aws_subnet.application_public.id
  route_table_id = aws_route_table.main.id
}

# Create a Security Group for the ALB
resource "aws_security_group" "alb" {
  name_prefix = "alb-"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0
