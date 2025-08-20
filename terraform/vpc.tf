data "aws_availability_zones" "available_primary" {
  provider = aws.primary
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Primary VPC

module "vpc" {
  source   = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.primary
  }
  version  = "6.0.1"
  name = "events-vpc"
  cidr = var.primary_cidr
  azs  = slice(data.aws_availability_zones.available_primary.names, 0, 3)
  private_subnets = var.primary_vpc_private
  public_subnets  = var.primary_vpc_public
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "cluster" = "${var.cluster_name}-public"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "cluster" = "${var.cluster_name}-private"
  }
}