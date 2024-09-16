# NAT Gateway for the Primary VPC (requires an EIP)
resource "aws_eip" "primary_nat_eip" {
}

resource "aws_nat_gateway" "primary_nat_gw" {
  allocation_id = aws_eip.primary_nat_eip.id
  subnet_id     = aws_subnet.primary_public_subnet.id

  tags = {
    Name = "PrimaryNATGW"
  }
}

# NAT Gateway for the Secondary VPC (requires an EIP)
resource "aws_eip" "Secondary_nat_eip" {
  provider = aws.secondary
}

resource "aws_nat_gateway" "Secondary_nat_gw" {
  provider = aws.secondary
  allocation_id = aws_eip.Secondary_nat_eip.id # Corrected to use Secondary_nat_eip
  subnet_id     = aws_subnet.secondary_public_subnet.id

  tags = {
    Name = "SecondaryNATGW"
  }

  depends_on = [
    aws_eip.Secondary_nat_eip
  ]
}