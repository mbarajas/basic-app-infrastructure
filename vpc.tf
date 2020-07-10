resource "aws_vpc" "app-test-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  enable_classiclink = "false"
  instance_tenancy = "default"

  tags = {
    Name = "app-test"
  }
}

resource "aws_subnet" "app-test-subnet-public-1" {
    vpc_id = "${aws_vpc.app-test-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"

    tags = {
        Name = "app-test-subnet-public-1"
    }
}

resource "aws_subnet" "app-test-subnet-public-2" {
    vpc_id = "${aws_vpc.app-test-vpc.id}"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"

    tags = {
        Name = "app-test-subnet-public-2"
    }
}

resource "aws_internet_gateway" "app-test-igw" {
  vpc_id = "${aws_vpc.app-test-vpc.id}"
  tags = {
    Name = "app-test-igw"
  }
}

resource "aws_route_table" "app-test-public-crt" {
  vpc_id = "${aws_vpc.app-test-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.app-test-igw.id}"
  }

  tags = {
    Name = "app-test-public-crt"
  }
}

resource "aws_route_table_association" "app-test-crta-public-subnet-1"{
  subnet_id = "${aws_subnet.app-test-subnet-public-1.id}"
  route_table_id = "${aws_route_table.app-test-public-crt.id}"
}

resource "aws_security_group" "app-test-sg" {
  vpc_id = "${aws_vpc.app-test-vpc.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-test-sg"
  }
}
