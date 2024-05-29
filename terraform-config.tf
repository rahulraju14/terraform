terraform {
required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = var.dss_new_profile
}

# module "create-aws-ec2-instance" {
#     source = "./aws_ec2_instance"
#     ami_id = "ami-0c7217cdde317cfec"
#     instance_type = "t2.micro"
#     instance_name = "tf-test-instance-4-b"
#     security_group_ids = [module.create-aws-security_group.sg_group_id]
#     git_user = var.secret_code_commit_user
#     git_password = var.secret_code_commit_password
#     aws_access_key = var.token_aws_access_key
#     aws_secret_key = var.token_aws_secret_key
# }

# --------------- EC2 INSTANCE CREATION ------------------------ 
module "create_public_aws_ec2_instance_vpc_01" {
    source = "./aws_ec2_instance"
    ami_id = "ami-0c7217cdde317cfec"
    instance_type = "t2.micro"
    instance_name = "tf_test_public_instance_vpc_01"
    security_group_ids = [module.create_public_instance_security_group_vpc_01.id]
    allocate_subnet_id = module.create_public_subnet_vpc_01.subnet_id
    associate_public_ip_address = true
    key_pair_name = "public_instance_kp"
}
module "create_private_aws_ec2_instance_vpc_02" {
    source = "./aws_ec2_instance"
    ami_id = "ami-0c7217cdde317cfec"
    instance_type = "t2.micro"
    instance_name = "tf_test_private_instance_vpc_02"
    security_group_ids = [module.create_private_instance_security_group_vpc_02.id]
    allocate_subnet_id = module.create_private_subnet_vpc_02.subnet_id
    associate_public_ip_address = false
    key_pair_name = "private_instance_kp"
}
# -------------------------------------------------------------

# --------------- SECURITY GROUP CREATION ---------------------
module "create_public_instance_security_group_vpc_01" {
    source = "./aws_security_groups"
    security_group_name = "tf_public_instance_sg_01_vpc_01"
    vpc_id = module.create_vpc_01.vpc_id
    ingress_data_list = [{cidr_blocks = ["0.0.0.0/0"], description = "Allow SSH from anywhere", from_port = 22, to_port = 22, protocol = "tcp"}, 
    {cidr_blocks = ["0.0.0.0/0"], description = "Allow tomcat port 8080 for accessing application", from_port = 8080, to_port = 8080, protocol = "tcp"}]
}

module "create_private_instance_security_group_vpc_02" {
    source = "./aws_security_groups"
    security_group_name = "tf_private_instance_sg_02_vpc_02"
    vpc_id = module.create_vpc_02.vpc_id
    ingress_data_list = [{cidr_blocks = [module.create_public_subnet_vpc_01.subnet_cidr_block], description = "Allow SSH from public subnet based instance", from_port = 22, to_port = 22, protocol = "tcp"}, 
    {cidr_blocks = [module.create_public_subnet_vpc_01.subnet_cidr_block], description = "Allow ping from public subnet based instance", from_port = -1, to_port = -1, protocol = "ICMP"}]
}
# -------------------------------------------------------------

# --------------- VPC CREATION -------------------------------- 
module "create_vpc_01" {
  source = "./aws_vpc/vpc"
  vpc_name = "tf_test_vpc_01"
  vpc_cidr_block = "20.0.0.0/16"
}

module "create_vpc_02" {
  source = "./aws_vpc/vpc"
  vpc_name = "tf_test_vpc_02"
  vpc_cidr_block = "30.0.0.0/16"
}
# ----------------------------------------------------------------

# --------------- SUBNET CREATION --------------------------------
module "create_public_subnet_vpc_01" {
  source = "./aws_vpc/subnet"
  subnet_name = "tf_vpc_01_public_subnet"
  subnet_cidr_block = "20.0.1.0/24"
  # vpc_id = module.create_vpc_01.vpc_id
  vpc_id = ""
}

module "create_private_subnet_vpc_01" {
  source = "./aws_vpc/subnet"
  subnet_name = "tf_vpc_01_private_subnet"
  subnet_cidr_block = "20.0.2.0/24"
  vpc_id = module.create_vpc_01.vpc_id
}

module "create_private_subnet_vpc_02" {
  source = "./aws_vpc/subnet"
  subnet_name = "tf_vpc_02_private_subnet"
  subnet_cidr_block = "30.0.3.0/24"
  vpc_id = module.create_vpc_02.vpc_id
}
# ----------------------------------------------------------------

# --------------- ROUTE TABLE && CONFIG CREATION -----------------
module "create_public_route_table_vpc_01" {
  source = "./aws_vpc/route_table/public"
  route_table_name = "tf_public_route_table_vpc_01"
  public_subnet_id = module.create_public_subnet_vpc_01.subnet_id
  internet_gateway_name = "tf_test_igw_01"
  vpc_id = module.create_vpc_01.vpc_id
}

module "create_public_route_config_vpc_01" {
  source = "./aws_vpc/route_config/public"
  destination_cidr_block = "0.0.0.0/0"
  internet_gateway_id = module.create_public_route_table_vpc_01.internet_gateway_id
  route_table_id = module.create_public_route_table_vpc_01.route_table_id
}

module "create_private_route_table_vpc_02" {
  source = "./aws_vpc/route_table/private"
  route_table_name = "tf_private_route_table_vpc_02"
  private_subnet_id  = module.create_private_subnet_vpc_02.subnet_id
  nat_gateway_name = "tf_test_nat_gateway_01"
  vpc_id = module.create_vpc_02.vpc_id
  attach_public_subnet_nat = module.create_public_subnet_vpc_01.subnet_id
}
# ----------------------------------------------------------------

# ------------- Module Validation --------------------------------

data "aws_vpc" "module_vpc_id" {
  id = module.create_vpc_01.vpc_id
}

module "module_validation" {
  source = "./module_validation"
  validation_attributes = {
    subnet_assosicated_vpc_id = module.create_public_subnet_vpc_01.subnet_assosicated_vpc_id
    subnet_name = module.create_public_subnet_vpc_01.subnet_name
    module_vpc_id = data.aws_vpc.module_vpc_id
  }
}