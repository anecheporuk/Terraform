##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}

variable "key_name" {
  default = "anecheporuk-air"
}

variable "availability-zones" {
  default = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c",
    "us-east-2e",
  ]

  type = "list"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-2"
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_instance" "nat_instance" {
  ami                    = "ami-021e3167"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  source_dest_check      = "false"
  vpc_security_group_ids = ["${aws_security_group.terraform_SG.id}"]
  subnet_id              = "${aws_subnet.public-a.id}"
  user_data              = "${file("jenkins_userdata.sh")}"

  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }

  tags {
    Name = "nat_instance"
  }
}

resource "aws_instance" "simple_instance" {
  ami                    = "ami-03291866"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.terraform_SG.id}"]
  subnet_id              = "${aws_subnet.private-a.id}"
  user_data              = "${file("tomcat_userdata.sh")}"

  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }

  tags {
    Name = "second_instance"
  }
}

resource "aws_security_group" "terraform_SG" {
  name   = "terraform security group"
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/26"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["188.163.232.130/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["37.115.191.123/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "terraformIGW" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  tags {
    Name = "terraformIGW"
  }
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/26"

  tags {
    Name = "terraform_vpc"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id                  = "${aws_vpc.terraform_vpc.id}"
  cidr_block              = "10.0.0.32/28"
  map_public_ip_on_launch = "true"

  #  availability_zone = "${var.availability-zones[count.index]}"
  availability_zone = "us-east-2a"

  tags {
    Name = "Public-a"
  }
}

#resource "aws_subnet" "Public-b" {
#  vpc_id     = "${aws_vpc.terraform_vpc.id}"
#  cidr_block = "10.0.0.48/28"
#
#  tags {
#    Name = "Public-b"
#  }
#}

resource "aws_subnet" "private-a" {
  vpc_id                  = "${aws_vpc.terraform_vpc.id}"
  cidr_block              = "10.0.0.0/28"
  map_public_ip_on_launch = "false"

  # availability_zone = "${var.availability-zones[count.index]}"
  availability_zone = "us-east-2a"

  tags {
    Name = "terraform_private-a"
  }
}

#resource "aws_subnet" "Private-b" {
#  vpc_id     = "${aws_vpc.terraform_vpc.id}"
#  cidr_block = "10.0.0.16/28"
#
#  tags {
#    Name = "terraform_private-b"
#  }
#}

resource "aws_route_table" "public-a" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terraformIGW.id}"
  }

  tags {
    Name = "terraform_public-a"
  }
}

resource "aws_route_table" "private-a" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat_instance.id}"

    #network_interface_id = "${aws_instance.nat_instance.network_interface_id}"
  }

  tags {
    Name = "terraform_private-a"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public-a.id}"
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = "${aws_subnet.private-a.id}"
  route_table_id = "${aws_route_table.private-a.id}"
}

##################################################################################
# OUTPUT
##################################################################################

#output "aws_instance_public_dns" {
#  value = "${aws_instance.nat_instance.public_dns}"
#}

output "Nat instance public IP " {
  value = "${aws_instance.nat_instance.public_ip}"
}

output "Simple instance private IP " {
  value = "${aws_instance.simple_instance.private_ip}"
}
