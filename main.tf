provider "aws" {
  region = "us-east-1"
}

variable "availability_zone" {
  description = "The AWS availability zone to deploy the instance and volume"
  type        = string
  default     = "us-east-1a"
}

resource "aws_instance" "scylla_db_instance" {
  ami           = "ami-0a0e5d9c7acc336f1"
  instance_type = "t2.medium"
  availability_zone = var.availability_zone

  root_block_device {
    volume_size = 15
  }

  tags = {
    Name        = "Scylla DB"
    Environment = "Dev"
    Project     = "TerraformDemo"
  }
}

resource "aws_ebs_volume" "scylla_db_volume" {
  availability_zone = var.availability_zone
  size              = 15
  tags = {
    Name        = "Scylla DB Volume"
    Environment = "Dev"
    Project     = "OT-Microservice"
  }
}

resource "aws_volume_attachment" "scylla_db_attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.scylla_db_volume.id
  instance_id = aws_instance.scylla_db_instance.id
}
####
