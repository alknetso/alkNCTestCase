
# ------------------------------------------------------------------------------
# AWS VPC Route Table
# ------------------------------------------------------------------------------
resource "aws_route_table" "alkNC-rt" {
  vpc_id                    = data.aws_vpc.alkNC-vpc.id
  tags = {
    Name                    = "alkNC-rt"
  }
}

# ------------------------------------------------------------------------------
# AWS VPC Internet Gateway
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "alkNC-ig" {
  vpc_id                    = data.aws_vpc.alkNC-vpc.id
  tags = {
    Name                    = "alkNC-ig"
  }
}

### Add default route to main table "alkNC-rt"
resource "aws_route" "alkNC-ig" {
  route_table_id            = aws_route_table.alkNC-rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.alkNC-ig.id
}

