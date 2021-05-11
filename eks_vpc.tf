provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "tf_demo" {
  cidr_block = "10.111.0.0/16"
  tags = {
    Name = "tf_demo"
  }
}

resource "aws_subnet" "public-1a" {
  vpc_id     = aws_vpc.tf_demo.id
  cidr_block = "10.111.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-1a"
  }
}

resource "aws_subnet" "public-1c" {
  vpc_id     = aws_vpc.tf_demo.id
  cidr_block = "10.111.2.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "public-1c"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tf_demo.id

  tags = {
    Name = "tf_demo_igw"
  }
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-1a.id

  tags = {
    Name = "tf_demo_NAT"
  }
}

resource "aws_subnet" "private-1a" {
  vpc_id     = aws_vpc.tf_demo.id
  cidr_block = "10.111.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-1a"
  }
}

resource "aws_subnet" "private-1c" {
  vpc_id     = aws_vpc.tf_demo.id
  cidr_block = "10.111.4.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "private-1c"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tf_demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.tf_demo.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  route {
    cidr_block = "10.100.0.0/16"
    vpc_peering_connection_id = "pcx-09d1f3c14fbd84ef9"
  }

  tags = {
    Name = "private"
  }
}


resource "aws_route_table_association" "a-public" {
  subnet_id      = aws_subnet.public-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "a-private" {
  subnet_id      = aws_subnet.private-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "c-public" {
  subnet_id      = aws_subnet.public-1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "c-private" {
  subnet_id      = aws_subnet.private-1c.id
  route_table_id = aws_route_table.private.id
}