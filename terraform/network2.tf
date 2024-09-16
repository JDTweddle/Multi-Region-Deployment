#secondary_vpc, secondary_sg, secondary_public_subnet, secondary_private_subnet, secondary_igw, secondary_nat_eip, secondary_nat_gw, secondary_public_rt, secondary_public_rta, secondary_private_rt, secondary_private_rta
resource "aws_vpc" "secondary_vpc" {
  provider = aws.secondary
  cidr_block = "10.1.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
	Name = "SecondaryVPC"
  }
}

resource "aws_network_acl" "secondary_acl" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id
  tags   = { Name = "SecondaryACL" }
}

resource "aws_network_acl_rule" "secondary_allow_http" {
  provider = aws.secondary
  network_acl_id = aws_network_acl.secondary_acl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "secondary_allow_https" {
  provider = aws.secondary
  network_acl_id = aws_network_acl.secondary_acl.id
  rule_number    = 101
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Public and Private Subnets in the Secondary VPC
resource "aws_subnet" "secondary_public_subnet" {
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"

  tags = {
    Name = "SecondaryPublicSubnet"
  }
}

resource "aws_subnet" "secondary_private_subnet" {
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "SecondaryPrivateSubnet"
  }
}

resource "aws_network_acl_association" "secondary_public_subnet_association" {
  provider      = aws.secondary
  subnet_id     = aws_subnet.secondary_public_subnet.id
  network_acl_id = aws_network_acl.secondary_acl.id
}

resource "aws_network_acl_association" "secondary_private_subnet_association" {
  provider      = aws.secondary
  subnet_id     = aws_subnet.secondary_private_subnet.id
  network_acl_id = aws_network_acl.secondary_acl.id
}

# Internet Gateway for the Primary VPC
resource "aws_internet_gateway" "secondary_igw" {
    provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id

  tags = {
    Name = "SecondaryIGW"
  }
}

resource "aws_route_table" "Secondary_public_rt" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }

  tags = {
    Name = "SecondaryPublicRT"
  }

  depends_on = [
    aws_internet_gateway.secondary_igw
  ]
}

resource "aws_route_table_association" "secondary_public_rt" {
  provider = aws.secondary
  subnet_id      = aws_subnet.secondary_public_subnet.id
  route_table_id = aws_route_table.Secondary_public_rt.id

  depends_on = [
    aws_route_table.Secondary_public_rt,
    aws_subnet.secondary_public_subnet
  ]
}

resource "aws_route_table" "secondary_private_rt" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Secondary_nat_gw.id # Corrected to use Secondary_nat_gw
  }

  tags = {
    Name = "SecondaryPrivateRT"
  }

  depends_on = [
    aws_nat_gateway.Secondary_nat_gw
  ]
}

resource "aws_route_table_association" "secondary_private_rta" {
  provider = aws.secondary
  subnet_id      = aws_subnet.secondary_private_subnet.id
  route_table_id = aws_route_table.secondary_private_rt.id

  depends_on = [
    aws_route_table.secondary_private_rt,
    aws_subnet.secondary_private_subnet
  ]
}
