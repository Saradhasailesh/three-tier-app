resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name   = "three-tier-app-vpc"
    region = var.region
  }
}

data "aws_availability_zones" "available" {
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private_subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.101.0/24"

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_security_group" "allow_ssh" {
  name   = "jump-server-sg"
  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }
}

resource "aws_security_group" "allow_http" {
  name   = "lb-sg"
  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "allow_http_ssh" {
  name   = "app-server-sg"
  vpc_id = aws_vpc.demo_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }
}



resource "aws_internet_gateway" "demo_ig" {
  vpc_id = aws_vpc.demo_vpc.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_route_table" "rt_demo" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_ig.id
  }
}

resource "aws_route_table" "rt_nat" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

}

resource "aws_route_table_association" "rt_association_private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.rt_nat.id
}


resource "aws_route_table_association" "rt_association_public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt_demo.id
}



