# Automated Zero-Trust GitOps Security & Event-Driven Monitoring Pipeline
# File Path: enterprise-gitops-pipelines/terraform/main.tf

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1" # Tokyo Region
}

# 1. Main Network Topology (VPC Architecture)
resource "aws_vpc" "gitops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name        = "Woven-Simulation-VPC"
    Environment = "Offensive-Security-Lab"
  }
}

# 2. Public Subnet Layer (Offensive Attack Node Boundary)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.gitops_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
  tags = { Name = "Attack-Boundary-Subnet" }
}

# 3. Private Subnet Layer (Hardened Target Corporate Environment)
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.gitops_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = { Name = "Hardened-Target-Subnet" }
}

# 4. Target Node Instance Profile (Hardened Rocky Linux Server)
resource "aws_instance" "target_server" {
  ami           = "ami-0d52744d6551d851e" # Mock Rocky Linux 9 AMI ID
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet.id
  tags = {
    Name        = "rocky-linux-target-node"
    OS_Flavor   = "Rocky Linux 9"
    Sec_Posture = "CIS-Hardened"
  }
}
