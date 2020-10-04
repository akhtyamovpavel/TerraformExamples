provider "aws" {
    region = "us-west-2"
}

resource "aws_instance" "example" {
    ami = "ami-06e54d05255faf8f6"
    instance_type = "t2.micro"

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello world" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    tags = {
        Name = "terraform-example"
    }
    
    vpc_security_group_ids = [aws_security_group.instance.id]
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "server_port" {
    description = "Where port to run"
    type = number
    default = 8080
}

output "public_ip" {
    value = aws_instance.example.public_ip
    description = "Public ip of server"
}


