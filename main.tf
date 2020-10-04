provider "aws" {
    region = "us-west-2"
}

resource "aws_launch_configuration" "example" {
    image_id = "ami-06e54d05255faf8f6"
    instance_type = "t2.micro"
    
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello world" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    
    security_groups = [aws_security_group.instance.id]

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name

    vpc_zone_identifier = data.aws_subnet_ids.default.ids
    min_size = 2
    max_size = 10
    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
}

# Data - read only form source
# aws - provider, vpc - virtual private cloud
data "aws_vpc" "default" {
    default = true
}

# Get subnet ids for launch_configuration
data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
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

