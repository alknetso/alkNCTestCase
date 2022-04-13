/*
 *  Alk-Netcracker Test Case
 *    INFRA
 *
 * Configuration variables,mostly for objects defined in other sections,
 * which can't be read directly.
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


