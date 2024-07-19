# main.tf

provider "aws" {
  region = "us-west-2" # Adjust the region as needed
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "dev_sg" {
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9042
    to_port     = 9042
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

resource "aws_instance" "scylla" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu Server 20.04 LTS (Change as needed)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.dev_subnet.id
  security_groups = [aws_security_group.dev_sg.name]

  tags = {
    Name = "ScyllaDB-Instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https curl",
      "curl -s https://s3.amazonaws.com/downloads.scylladb.com/deb/unstable/ubuntu/scylladb-4.3.0/Release.key | sudo apt-key add -",
      "echo 'deb https://s3.amazonaws.com/downloads.scylladb.com/deb/unstable/ubuntu/scylladb-4.3.0 focal main' | sudo tee /etc/apt/sources.list.d/scylla.list",
      "sudo apt-get update -y",
      "sudo apt-get install -y scylla",
      "sudo scylla_setup --no-ec2-check",
      "sudo systemctl start scylla-server"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}

output "ec2_public_ip" {
  value = aws_instance.scylla.public_ip
}
