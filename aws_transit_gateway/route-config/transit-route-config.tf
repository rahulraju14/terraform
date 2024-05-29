# resource "aws_ec2_transit_gateway_route_table" "transit_gateway_route_table" {
#   transit_gateway_id = var.transit_gateway_id
# }

# resource "aws_ec2_transit_gateway_route_table_association" "transit_gateway_rt_vpc_assosication" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.example.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.example.id
# }