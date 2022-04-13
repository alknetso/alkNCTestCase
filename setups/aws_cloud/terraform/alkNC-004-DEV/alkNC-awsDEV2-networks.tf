/*
 *  Alk-Netcracker Test Case
 *    GLOBAL
 *      Subnet "DEV"
 *    Owners:
 *      - Alexandre Kouznetsov <alk@alknetso.com>
 *    Subnets to use:
 *      - "Operation" 10.200.4.0/22 (255.255.252.0)
 *        - "Development" 10.200.4.0/24 (255.255.255.0)
 *
 * Set up networking and other parameters
 * general for DEV stage of operation
 */


# Subnet to use in stage DEV availability zone A
resource "aws_subnet" "alkNC-dev_us-east-1a_nw" {
  vpc_id                  = data.aws_vpc.alkNC-vpc.id
  cidr_block              = "10.200.4.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "alkNC-dev_us-east-1a_nw"
  }
}
resource "aws_route_table_association" "alkNC-rta-dev_us-east-1a_nw" {
  route_table_id = data.aws_route_table.alkNC-rt.id
  subnet_id      = aws_subnet.alkNC-dev_us-east-1a_nw.id
}


# Subnet to use in stage DEV availability zone B
resource "aws_subnet" "alkNC-dev_us-east-1b_nw" {
  vpc_id                  = data.aws_vpc.alkNC-vpc.id
  cidr_block              = "10.200.4.64/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "alkNC-dev_us-east-1b_nw"
  }
}
resource "aws_route_table_association" "alkNC-rta-dev_us-east-1b_nw" {
  route_table_id = data.aws_route_table.alkNC-rt.id
  subnet_id      = aws_subnet.alkNC-dev_us-east-1b_nw.id
}

# Subnet to use in stage DEV availability zone C - Reserved
# resource "aws_subnet" "alkNC-dev_us-east-1c_nw" {
#   vpc_id     = "${data.aws_vpc.alkNC-vpc.id}"
#   cidr_block = "10.200.4.128/26"
#   availability_zone = "us-east-1c"
#   map_public_ip_on_launch = true
#
#   tags = {
#     Name = "alkNC-dev_us-east-2c_nw"
#   }
# }
#resource "aws_route_table_association" "alkNC-rta-dev_us-east-1c_nw" {
#  route_table_id = data.aws_route_table.alkNC-rt.id
#  subnet_id      = aws_subnet.alkNC-dev_us-east-1c_nw.id
#}


