/*
 *  Alk-Netcracker Test Case
 *    Frontend
 *      Subnet "DEV"
 *    Owners:
 *      - Alexandre Kouznetsov <alk@alknetso.com>
 *    Subnets to use:
 *      - "Operation" 10.200.4.0/22 (255.255.252.0)
 *        - "Development" 10.200.4.0/24 (255.255.255.0)
 */


# Variables general for "Frontend" infrastructure.
/*
#Reserved IP blocks for Frontend instances
#  AZ A: 10.200.4.12/30
#  AZ B: 10.200.4.76/30
variable "alkNC-dev-frontend-ips" {
  description                 = "Private IPs for Frontend instances"
  type                        = list(string)
  default                     = [
                                "10.200.4.12", "10.200.4.76",
                                "10.200.4.13", "10.200.4.77",
                                "10.200.4.14", "10.200.4.78",
                                "10.200.4.15", "10.200.4.79",
                              ]
}
*/

# Security Group(s) for "Frontend" infrastructure.
resource "aws_security_group" "alkNC-dev-frontend-sg" {
  name        = "alkNC-dev-frontend-sg"
  description = "Alk-Netcracker Development Frontend Security Group"
  vpc_id      = data.aws_vpc.alkNC-vpc.id
  tags = {
    "Name" = "alkNC-dev-frontend-sg"
  }
}
resource "aws_security_group_rule" "alkNC-dev-frontend-FromSelf-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-frontend-sg.id
  type                 = "ingress"
  from_port            = 0
  to_port              = 0
  protocol             = "-1"
  self                 = true
  description          = "From Self"
}
resource "aws_security_group_rule" "alkNC-dev-frontend-ToInternet-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-frontend-sg.id
  type                 = "egress"
  from_port            = 0
  to_port              = 0
  protocol             = "-1"
  cidr_blocks          = ["0.0.0.0/0"]
  description          = "To Internet"
}

resource "aws_security_group_rule" "alkNC-dev-frontend-FromSysAdminsICMP-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-frontend-sg.id
  type                 = "ingress"
  from_port            = 8
  to_port              = -1
  protocol             = "icmp"
  cidr_blocks          = "${var.SysAdminsIPs}"
  description          = "From SysAdmins"
}
resource "aws_security_group_rule" "alkNC-dev-frontend-FromSysAdminsSSH-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-frontend-sg.id
  type                 = "ingress"
  from_port            = 22
  to_port              = 22
  protocol             = "tcp"
  cidr_blocks          = "${var.SysAdminsIPs}"
  description          = "From SysAdmins"
}

resource "aws_security_group_rule" "alkNC-dev-frontend-ToBackendICMP-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-frontend-sg.id
  type                 = "egress"
  from_port            = 8
  to_port              = -1
  protocol             = "icmp"
  source_security_group_id = aws_security_group.alkNC-dev-backend-sg.id
  description          = "To Backend"
}
resource "aws_security_group_rule" "alkNC-dev-frontend-ToBackendNetdata-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-frontend-sg.id
  type                 = "egress"
  from_port            = 19999
  to_port              = 19999
  protocol             = "tcp"
  source_security_group_id = aws_security_group.alkNC-dev-backend-sg.id
  description          = "To Backend"
}

resource "aws_security_group_rule" "alkNC-dev-frontend-FromWebClientsHTTP-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-frontend-sg.id
  type                 = "ingress"
  from_port            = 80
  to_port              = 80
  protocol             = "tcp"
  cidr_blocks          = "${var.WebClientsIPs}"
  description          = "From WebClients"
}

# EC2 Instance(s) for  "Frontend" infrastructure.

resource "aws_instance" "alkNC-dev-frontend" {
#  count                       = "1"
  ami                         = var.ami-centos8-64
  availability_zone           = "us-east-1a"
  ebs_optimized               = false
  instance_type               = "t2.nano"
  monitoring                  = false
  key_name                    = "alkNC-deployer-key"
  subnet_id                   = aws_subnet.alkNC-dev_us-east-1a_nw.id
  vpc_security_group_ids      = [
                                  aws_security_group.alkNC-dev-frontend-sg.id,
                                ]
  associate_public_ip_address = true
#  private_ip                  = element(var.alkNC-dev-frontend-ips, count.index)
  private_ip                  = "10.200.4.12"
  source_dest_check           = true
#  disable_api_termination     = true
  disable_api_termination     = false

  volume_tags = {
    "Name"                    = "alkNC-dev-frontend-disk"
  }
  root_block_device {
    volume_type               = "gp2"
    volume_size               = 10
    delete_on_termination     = true
  }
#Normally, we use a secondary storage block device on EC2 instances,
#but not in this project.
#  ebs_block_device {
#    device_name               = "/dev/xvdb"
#    volume_type               = "gp2"
#    volume_size               = 10
#    delete_on_termination     = true
#    encrypted                 = true
#  }

  tags = {
#Normally, we use a more descriptive names for EC2 instances,
#but not in this project.
#    "Name"                    = "alkNC-dev-frontend"
    "Name"                    = "c8"
    "Stage"                   = "DEV"
  }
  lifecycle {
    ignore_changes = [ associate_public_ip_address ]
  }
}

#2DO: use variables for GROUP and HOST instead of hardcoding values
#2DO: Iterate over multiple EC2 instances to put them in the same inventory file
resource "local_file" "alkNC-dev-frontend-ansible_hosts" {
  content = templatefile("TFInventory-ansible_hosts.template",
    {
      GROUP = "frontend"
      HOST = "c8"
      ANSIBLE_HOST = element(aws_instance.alkNC-dev-frontend.*.public_dns, 0)
    }
  )
  filename = "../../ansible/TFInventory-alkNC-dev-frontend-ansible_hosts"
  directory_permission = "0750"
  file_permission      = "0640"
}

# Route 53 Record for this instance(s)
resource "aws_route53_record" "alkNC-dev-frontend-r53" {
#  count                       = "1"
  zone_id                     = data.aws_route53_zone.local-r53.id
  type                        = "A"
  name                        = "c8.local"
  records                     = ["10.200.4.12"]
#  name                        = "alkNC-dev-frontend-i${count.index + 1}.aws-us-west-2.alkNC.i"
#  records                     = [element(var.alkNC-dev-frontend-ips, count.index)]
  ttl                         = "300"
}

#Print reference information
output "alkNC-dev-frontend_ips" {
  value = aws_instance.alkNC-dev-frontend.*.public_dns
}

#ssh -i ~/NCTestCase/setups/aws_cloud/.secrets/alkNC-deployer-key_2022-04-04T200847 centos@ec2-54-173-106-110.compute-1.amazonaws.com



