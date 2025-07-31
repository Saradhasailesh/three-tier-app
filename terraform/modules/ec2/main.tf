resource "aws_key_pair" "web-server-key" {
  key_name   = var.key_name
  public_key = var.public_key
}

data "aws_availability_zones" "available" {
  
}

resource "aws_instance" "app_server" {
    count = 2
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    availability_zone = data.aws_availability_zones.available.names[0]
    vpc_security_group_ids = var.security_group_ids
    subnet_id = var.private_subnet_id[count.index]
    associate_public_ip_address = false
    tags= {
        Name = "appserver-${count.index}"
    }    
}


resource "aws_instance" "jump_host" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    availability_zone = data.aws_availability_zones.available.names[0]
    vpc_security_group_ids = var.security_group_ids
    subnet_id = var.public_subnet_id
    associate_public_ip_address = true
    tags= {
        Name = "jump-host"
    }    
}

resource "aws_instance" "db_server" {
    count = 1
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    availability_zone = data.aws_availability_zones.available.names[0]
    vpc_security_group_ids = var.security_group_ids
    subnet_id = var.private_subnet_id[count.index % length(var.private_subnet_id)]
    associate_public_ip_address = false
    tags= {
        Name = "db-server"
    }    
}