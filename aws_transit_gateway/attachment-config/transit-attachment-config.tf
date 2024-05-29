module "common_variables" {
  source = "../common"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tf_transit_gateway_attachment" {
  subnet_ids         = module.common_variables.subnet_ids
  transit_gateway_id = module.common_variables.transit_gateway_id
  vpc_id             = module.common_variables.vpc_id
  
  tags = {
    Name = module.common_variables.transit_gateway_attachment_name 
  }
}

output "transit_gateway_vpc_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tf_transit_gateway_attachment.id
}