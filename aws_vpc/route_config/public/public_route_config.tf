resource "aws_route" "tf_public_route_igw_config" {
  route_table_id            = var.route_table_id
  destination_cidr_block    = var.destination_cidr_block
  gateway_id = var.internet_gateway_id
}