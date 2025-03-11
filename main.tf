provider "aws" {

  region = "ap-south-1"
  
}

resource "aws_instance" "mongodb" {
  ami           = "ami-08fe5144e4659a3b3"  
  instance_type = "t2.micro"
  key_name      = "my-key-pair"  
  security_groups = [aws_security_group.mongodb_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y

              # Add MongoDB 6.0 repository
              sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo <<EOL
              [mongodb-org-6.0]
              name=MongoDB Repository
              baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
              gpgcheck=1
              enabled=1
              gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
              EOL

              # Install MongoDB 6.0
              sudo yum install -y mongodb-org

              # Start and enable MongoDB service
              sudo systemctl start mongod
              sudo systemctl enable mongod
            EOF

  tags = {
    Name = "MongoDB-Server"
  }
}

resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb-sg"
  description = "Allow SSH and MongoDB access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
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


output "ec2_public_ip" {
  description = "Public IP of the MongoDB instance"
  value       = aws_instance.mongodb.public_ip
}
