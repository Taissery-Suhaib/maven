#configure the AWS provider new
#export AWS_ACCESS_KEY_ID=xx
#export AWS_SECRET_ACCESS_KEY=xx

provider "aws" {
    region     = "ap-south-1"
}

resource "aws_instance" "web" {
    ami 	  = "ami-0f5ee92e2d63afc18"
    instance_type = "t3.micro"
    subnet_id	  = "subnet-0d00647b0a6e6e2b5"
    key_name	  = "keypair-b2"
    vpc_security_group_ids = [
    "sg-0c4861a1b422c7c77"
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Name ="tf-server"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }
}


output "ec2instance" {
  value = aws_instance.web.public_ip
}
