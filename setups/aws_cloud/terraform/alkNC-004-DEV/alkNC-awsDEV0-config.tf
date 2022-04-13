/*
 *  Alk-Netcracker Test Case
 *    GLOBAL
 *      Subnet "OPER" Stage PRO
 *    Owners:
 *      - Alexandre Kouznetsov <alk@alknetso.com>
 *    Subnets to use:
 *      - "Operation" 10.200.4.0/22 (255.255.252.0)
 *        - "Development" 10.200.4.0/24 (255.255.255.0)
 *
 * Configuration variables,
 * mostly for objects defined in INFRA and a "global" section,
 * to be referenced to create infrastructure for DEV stage of operation.
 */

# Main VPC declaration
data "aws_vpc" "alkNC-vpc" {
  filter {
    name   = "tag:Name"
    values = ["alkNC-vpc"]
  }
}

# Availability zones to be used in this project
variable "azs" {
 description = "Run the EC2 Instances in these Availability Zones"
 type        = list(string)
 default     = [
                "us-east-1a",
                "us-east-1b",
               ]
  # us-east-1c is reserved
}

# Private DNS Zone "local" for shis project
data "aws_route53_zone" "local-r53" {
  name              = "local"
  private_zone      = true
}


# AWS VPC Subnets
# Not used, since we deploy in a single AZ
#locals {
#  alkNC-dev_us-east-1-subnets   = [
#                                    aws_subnet.alkNC-dev_us-east-1a_nw.id,
#                                    aws_subnet.alkNC-dev_us-east-1b_nw.id,
#                                  ]
#}

# Route table associated with out Main VPC
data "aws_route_table" "alkNC-rt" {
  filter {
    name        = "tag:Name"
    values      = ["alkNC-rt"]
  }
}


#IP addresses of divese entities to be addressed within SGs.
variable "SysAdminsIPs" {
  type        =  list(string)
  description = "Source IP addresses of System Administrators connections"
  default     = [
    "189.147.98.182/32", #alk@loreto 2022-04-05
    "189.147.35.245/32", #alk@loreto 2022-04-07
    "189.147.104.44/32", #alk@loreto 2022-04-11
    ]
}
variable "WebClientsIPs" {
  type        =  list(string)
  description = "Source IP addresses of Web Clients connections"
  default     = [
    "189.147.98.182/32", #alk@loreto 2022-04-05
    "189.147.35.245/32", #alk@loreto 2022-04-07
    "189.147.104.44/32", #alk@loreto 2022-04-11
   ]
}

# Amazon Machine Images definition to use for EC2 instances

#https://cloud-images.ubuntu.com/locator/ec2/
#ami-0fcda042dd8ae41c7
#ami-044f0ceee8e885e87
variable "ami-ubuntu2104-64" {
  description = "Ubuntu 21.04 - ubuntu-hirsute-amd64-hvm-20220118-ebs"
  default     = "ami-0fcda042dd8ae41c7"
}

#https://wiki.centos.org/Cloud/AWS
#CentOS Stream 8 x86_64 20210603, us-east-1, ami-0ee70e88eed976a1b
variable "ami-centos8-64" {
  description = "CentOS Stream 8 x86_64 20210603"
  default     = "ami-0ee70e88eed976a1b"
}


