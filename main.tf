provider "aws" {
	region = "us-east-1"
}
#test
#variable vpc_cidr_block {}
#variable subnet_cidr_block {}
variable avail_zone {}
#variable env_prefix {}
#variable my_ip {}
variable instance_type {} 
#variable public_key_location {}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "tf-Default-VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1"

  tags = {
    Name = "tf-Default-subnet"
  }
}

resource "aws_security_group" "myapp-sg" {
	name = "myapp-sg"
	vpc_id = aws_default_vpc.default.id
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 8080
		to_port = 8080
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		prefix_list_ids = []
	}

	tags = {
		Name = "tf-sg"
	}
}

data "aws_ami" "latest-amazon-linux-image" {
	most_recent = true 
	owners = ["amazon"]
	filter {
		name = "name"
		values = ["am*-x86_64-gp2"]
	}
	filter {
		name = "virtualization-type"
		values = ["hvm"]
	}
}
output "aws_ami" {
	value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_instance" "myapp-server" {
	ami = data.aws_ami.latest-amazon-linux-image.id
	instance_type = var.instance_type
	
	subnet_id = aws_default_subnet.default_az1.id
	vpc_security_group_ids = [aws_security_group.myapp-sg.id]
	availability_zone = var.avail_zone
	
	associate_public_ip_address = true
	key_name = "aws-freetair-key"
	
	tags = {
		Name = "tf-ec2"
	}
}
