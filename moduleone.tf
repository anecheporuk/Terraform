##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "anecheporuk-air"
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
  ami           = "ami-6a003c0f"
  instance_type = "t2.micro"
  key_name      = "${var.key_name}"
  source_dest_check = "false"

  connection {
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }
  
  tags {
    Name = "nat_instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install nginx -y",
      "sudo service nginx start"
    ]
  }
}

resource "aws_instance" "simple_instance" {
  ami           = "ami-6a003c0f"
  instance_type = "t2.micro"
  key_name      = "${var.key_name}"

  connection {
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install nginx -y",
      "sudo service nginx start"
    ]
  }
}

resource "aws_security_group" "terraform_vpc" {
  name          = "terraform security group"
  vpc_id        = "${aws_vpc.terraform_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = 0
    cidr_blocks = ["10.0.0.0/26"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/26"

  
}

resource "aws_internet_gateway" "terraformIGW" {
  
  vpc_id = "${aws_vpc.terraform_vpc.id}"
  
}

resource "aws_subnet" "Private-a" {
  vpc_id     = "${aws_vpc.terraform_vpc.id}"
  cidr_block = "10.0.0.0/28"

  tags {
    Name = "Private-a"
  }
}

resource "aws_subnet" "Private-b" {
  vpc_id     = "${aws_vpc.terraform_vpc.id}"
  cidr_block = "10.0.0.16/28"

  tags {
    Name = "Private-b"
  }
}

resource "aws_subnet" "Public-a" {
  vpc_id     = "${aws_vpc.terraform_vpc.id}"
  cidr_block = "10.0.0.32/28"

  tags {
    Name = "Public-a"
  }
}

resource "aws_subnet" "Public-b" {
  vpc_id     = "${aws_vpc.terraform_vpc.id}"
  cidr_block = "10.0.0.48/28"

  tags {
    Name = "Public-b"
  }
}

resource "aws_route_table" "Private" {
  vpc_id     = "${aws_vpc.terraform_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat_instance.id}"
  }

  tags {
    Name = "Private-Route-Table"
  }
}

resource "aws_route_table" "Public" {
  vpc_id     = "${aws_vpc.terraform_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat_instance.id}"
  }
  
  tags {
    Name = "Public-Route-Table"
  }
}


resource "aws_route_table_association" "Private" {
  subnet_id = "${aws_subnet.Private-a.id}"
  route_table_id = "${aws_route_table.Private.id}"
}

#resource "aws_route_table_association" "Private" {
#  subnet_id = "${aws_subnet.Private-b.id}"
#  route_table_id = "${aws_route_table.Private.id}"
#}

resource "aws_route_table_association" "Public" {
  subnet_id = "${aws_subnet.Public-a.id}"
  route_table_id = "${aws_route_table.Public.id}"
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
    value = "${aws_instance.nat_instance.public_dns}"
}
