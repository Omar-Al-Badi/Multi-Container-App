provider "aws" {
  profile = "DevOps_Omar"
  region  = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "jenkins-key"  # Create "jenkins-key" in AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "mkdir -p ~/.ssh && echo '${tls_private_key.pk.private_key_pem}' > ~/.ssh/jenkins-key.pem && chmod 600 ~/.ssh/jenkins-key.pem"
  }
}

resource "aws_instance" "Jenkins-t2-micro" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.kp.key_name
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "Jenkins-t2-micro"
  }

  root_block_device {
    volume_size = 15
  }

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.pk.private_key_pem
      host        = aws_instance.Jenkins-t2-micro.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' --private-key ~/.ssh/jenkins-key.pem provision.yaml"
  }
}

resource "aws_security_group" "main" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
   ingress {
    from_port = 3306
    to_port   = 3306 
    protocol  = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 4000
    to_port   = 4000
    protocol  = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  
   ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
