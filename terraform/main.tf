terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  region  = "eu-central-1"
  profile = "themoosalah"
}

# 🔹 Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 🔹 Use your manually created VPC
data "aws_vpc" "custom" {
  id = "vpc-0f6ef4508bcc5849b"
}

# 🔹 Use your existing public subnet (update CIDR if different)
data "aws_subnet" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.custom.id]
  }

  filter {
    name   = "cidr-block"
    values = ["10.0.1.0/24"]
  }
}

# 🔹 Security Group for the App
resource "aws_security_group" "app_sg" {
  name        = "app-securityGroup"
  description = "Allow HTTP access on 8080"
  vpc_id      = data.aws_vpc.custom.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# 🔹 IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 🔹 S3 Bucket for artifacts
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "spring-petclinic-artifacts-mofayad96"

  tags = {
    Name = "spring-petclinic-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "artifact_versioning" {
  bucket = aws_s3_bucket.artifact_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "artifact_lifecycle" {
  bucket = aws_s3_bucket.artifact_bucket.id

  rule {
    id     = "delete-old-artifacts"
    status = "Enabled"

    filter {
      prefix = "builds/"
    }

    expiration {
      days = 30
    }
  }
}

# 🔹 IAM Policy for EC2 to access S3
resource "aws_iam_role_policy" "s3_access" {
  name = "ec2-s3-access-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          aws_s3_bucket.artifact_bucket.arn,
          "${aws_s3_bucket.artifact_bucket.arn}/*"
        ]
      }
    ]
  })
}

# 🔹 IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# 🔹 EC2 Instance (Spring Petclinic)
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  tags = {
    Name = "Spring-petclinic_app"
  }
}


