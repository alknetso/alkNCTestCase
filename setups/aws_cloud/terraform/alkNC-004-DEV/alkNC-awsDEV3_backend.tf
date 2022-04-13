/*
 *  Alk-Netcracker Test Case
 *    Backend
 *      Subnet "DEV"
 *    Owners:
 *      - Alexandre Kouznetsov <alk@alknetso.com>
 *    Subnets to use:
 *      - "Operation" 10.200.4.0/22 (255.255.252.0)
 *        - "Development" 10.200.4.0/24 (255.255.255.0)
 */


# Variables general for "Backend" infrastructure.
/*
#Reserved IP blocks for Backend instances
#  AZ A: 10.200.4.8/30
#  AZ B: 10.200.4.72/30
variable "alkNC-dev-backend-ips" {
  description                 = "Private IPs for Backend instances"
  type                        = list(string)
  default                     = [
                                "10.200.4.8", "10.200.4.72",
                                "10.200.4.9", "10.200.4.73",
                                "10.200.4.10", "10.200.4.74",
                                "10.200.4.11", "10.200.4.75",
                              ]
}
*/


# Security Group(s) for "Backend" infrastructure.
resource "aws_security_group" "alkNC-dev-backend-sg" {
  name        = "alkNC-dev-backend-sg"
  description = "Alk-Netcracker Development Backend Security Group"
  vpc_id      = data.aws_vpc.alkNC-vpc.id
  tags = {
    "Name" = "alkNC-dev-backend-sg"
  }
}
resource "aws_security_group_rule" "alkNC-dev-backend-FromSelf-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-backend-sg.id
  type                 = "ingress"
  from_port            = 0
  to_port              = 0
  protocol             = "-1"
  self                 = true
  description          = "From Self"
}
resource "aws_security_group_rule" "alkNC-dev-backend-ToInternet-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-backend-sg.id
  type                 = "egress"
  from_port            = 0
  to_port              = 0
  protocol             = "-1"
  cidr_blocks          = ["0.0.0.0/0"]
  description          = "To Internet"
}

resource "aws_security_group_rule" "alkNC-dev-backend-FromSysAdminsICMP-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-backend-sg.id
  type                 = "ingress"
  from_port            = 8
  to_port              = -1
  protocol             = "icmp"
  cidr_blocks          = "${var.SysAdminsIPs}"
  description          = "From SysAdmins"
}
resource "aws_security_group_rule" "alkNC-dev-backend-FromSysAdminsSSH-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-backend-sg.id
  type                 = "ingress"
  from_port            = 22
  to_port              = 22
  protocol             = "tcp"
  cidr_blocks          = "${var.SysAdminsIPs}"
  description          = "From SysAdmins"
}

resource "aws_security_group_rule" "alkNC-dev-backend-FromFrontendICMP-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-backend-sg.id
  type                 = "ingress"
  from_port            = 8
  to_port              = -1
  protocol             = "icmp"
  source_security_group_id = aws_security_group.alkNC-dev-frontend-sg.id
  description          = "From Frontend"
}
resource "aws_security_group_rule" "alkNC-dev-backend-FromFrontendNetdata-sgrule" {
  security_group_id    = aws_security_group.alkNC-dev-backend-sg.id
  type                 = "ingress"
  from_port            = 19999
  to_port              = 19999
  protocol             = "tcp"
  source_security_group_id = aws_security_group.alkNC-dev-frontend-sg.id
  description          = "From Frontend"
}


# EC2 Instance(s) for  "Backend" infrastructure.
resource "aws_instance" "alkNC-dev-backend" {
  count                       = "1"
  ami                         = var.ami-ubuntu2104-64
  availability_zone           = "us-east-1a"
  ebs_optimized               = false
  instance_type               = "t2.nano"
  monitoring                  = false
  key_name                    = "alkNC-deployer-key"
  subnet_id                   = aws_subnet.alkNC-dev_us-east-1a_nw.id
  vpc_security_group_ids      = [
                                  aws_security_group.alkNC-dev-backend-sg.id,
                                ]
  associate_public_ip_address = true
#  private_ip                  = element(var.alkNC-dev-backend-ips, count.index)
  private_ip                  = "10.200.4.8"
  source_dest_check           = true
#  disable_api_termination     = true
  disable_api_termination     = false

  volume_tags = {
    "Name"                    = "alkNC-dev-backend-disk"
  }
  root_block_device {
    volume_type               = "gp2"
    volume_size               = 8
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
#    "Name"                    = "alkNC-dev-backend"
    "Name"                    = "u21"
    "Stage"                   = "DEV"
  }
  lifecycle {
    ignore_changes = [ associate_public_ip_address ]
  }
  provisioner "local-exec" {
    command = "echo IM PROVISIONER, new backend host u21 ${ element(aws_instance.alkNC-dev-backend.*.public_dns, 0) }"
#    command = "
#    ANSIBLE_HOST_KEY_CHECKING=False;
#    ansible-playbook -u {var.user} -i '${self.ipv4_address},' --private-key ${var.ssh_private_key} playbook.yml"
#    environment {
#      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
#      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
#      AWS_DEFAULT_REGION = "${var.region}"
#    }
  }
}

#2DO: use variables for GROUP and HOST instead of hardcoding values
#2DO: Iterate over multiple EC2 instances to put them in the same inventory file
resource "local_file" "alkNC-dev-backend-ansible_hosts" {
  content = templatefile("TFInventory-ansible_hosts.template",
    {
      GROUP = "backend"
      HOST = "u21"
      ANSIBLE_HOST = element(aws_instance.alkNC-dev-backend.*.public_dns, 0)
    }
  )
  filename = "../../ansible/TFInventory-alkNC-dev-backend-ansible_hosts"
  directory_permission = "0750"
  file_permission      = "0640"
}


# Route 53 Record for this instance(s)
resource "aws_route53_record" "alkNC-dev-backend-r53" {
#  count                       = "1"
  zone_id                     = data.aws_route53_zone.local-r53.id
  type                        = "A"
  name                        = "u21.local"
  records                     = ["10.200.4.8"]
#  name                        = "alkNC-dev-backend-i${count.index + 1}.aws-us-west-2.alkNC.i"
#  records                     = [element(var.alkNC-dev-backend-ips, count.index)]
  ttl                         = "600"
  provisioner "local-exec" {
    command = "echo IM PROVISIONER, new aws_route53_record alkNC-dev-backend-r53"
  }
}

#resource "local_file" "alkNC-dev-backend-r53-zonefile" {
#  content = templatefile("alkNC-dev-backend-r53.zone.template",
#    {
#      REC_NAME = aws_route53_record.alkNC-dev-backend-r53.name
#      REC_TTL = aws_route53_record.alkNC-dev-backend-r53.ttl
#      REC_TYPE = aws_route53_record.alkNC-dev-backend-r53.type
#      REC_VALUE = aws_route53_record.alkNC-dev-backend-r53.records.*
#    }
#  )
#Use with file alkNC-dev-backend-r53.zone.template:
#${REC_NAME}  ${REC_TTL}  IN  ${REC_TYPE}  ${REC_VALUE[0]}

#resource "local_file" "alkNC-dev-backend-r53-zonefile" {
#  content = "${aws_route53_record.alkNC-dev-backend-r53.name}  ${aws_route53_record.alkNC-dev-backend-r53.ttl}  IN  ${aws_route53_record.alkNC-dev-backend-r53.type}  ${ element(aws_route53_record.alkNC-dev-backend-r53.records.*, 0) }"
#  filename = "alkNC-dev-backend-r53.zone"
#  directory_permission = "0750"
#  file_permission      = "0640"
#}


/*
#Print reference information
output "alkNC-dev-backend_ips" {
  value = aws_instance.alkNC-dev-backend.*.public_dns
}
*/

#ssh -i ~/NCTestCase/setups/aws_cloud/.secrets/alkNC-deployer-key_2022-04-04T200847 ubuntu@ec2-54-243-1-188.compute-1.amazonaws.com



