provider "aws" {
    region = "us-west-2"
}

resource "aws_instance" "example" {
    ami = "ami-06e54d05255faf8f6"
    instance_type = "t2.micro"
    tags = {
        Name = "terraform-example"
    }
}
