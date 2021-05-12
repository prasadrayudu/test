provider "aws" {
  region  = "ap-south-1" 
  profile = "default"     

  ignore_tags {
   key_prefixes = ["kubernetes.io"]
  }
}
data "aws_region" "current" {}
data "aws_availability_zones" "all" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "k3s"
  cidr = "10.0.0.0/16"

  azs                  = data.aws_availability_zones.all.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  # optionally,
  enable_nat_gateway = true
  single_nat_gateway = true 

  tags = {
    "Name" = "my-k3s-vpc"
  }
}

# Main module

module "k3s_cluster" {
  source = "./modules/k3s_cluster"
  cluster_id = "k3s-in-new-vpc"
  region             = data.aws_region.current.name
  availability_zones = data.aws_availability_zones.all.names
  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  private_subnets    = module.vpc.private_subnets
  master_instance_type = "t3a.small"
  node_count           = 3
  node_instance_arch   = "x86_64"
  node_instance_types  = ["t3a.small", "t3.small"]
  on_demand_percentage = 0 

}
