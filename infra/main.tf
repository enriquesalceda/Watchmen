terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_vpc" "vpc-compliance-as-code-presentation" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "compliance-as-code-presentation"
  }
}

resource "aws_subnet" "private-subnet-compliance-as-code-presentation-1" {
  vpc_id            = aws_vpc.vpc-compliance-as-code-presentation.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-2a"
}

resource "aws_subnet" "private-subnet-compliance-as-code-presentation-2" {
  vpc_id            = aws_vpc.vpc-compliance-as-code-presentation.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-southeast-2b"
}

resource "aws_db_subnet_group" "db-subnet-compliance-as-code-presentation" {
  name       = "db subnet group"
  subnet_ids = [aws_subnet.private-subnet-compliance-as-code-presentation-1.id, aws_subnet.private-subnet-compliance-as-code-presentation-2.id]
}

resource "aws_db_instance" "compliant-aws-rds" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "14.2"
  instance_class       = "db.t3.micro"
  name                 = "compliant"
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.db-subnet-compliance-as-code-presentation.name
  storage_encrypted    = true

  tags = {
    Family = "compliance-as-code-presentation"
  }
}

resource "aws_db_instance" "defiant-aws-rds" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "14.2"
  instance_class       = "db.t3.micro"
  name                 = "defiant"
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.db-subnet-compliance-as-code-presentation.name

  tags = {
    Family = "compliance-as-code-presentation"
  }
}

resource "aws_s3_bucket" "compliant-aws-s3-bucket" {
  bucket = "compliant-aws-s3-bucket"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Family = "compliance-as-code-presentation"
  }
}

resource "aws_s3_bucket" "defiant-aws-s3-bucket" {
  bucket = "defiant-aws-s3-bucket"
  tags = {
    Family = "compliance-as-code-presentation"
  }
}
