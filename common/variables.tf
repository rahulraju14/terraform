variable "transit_gateway_attachment_name" {
  type = string
  default = "transit_gateway_attachment"
}

output "transit_gateway_attachment_name" {
  value = var.transit_gateway_attachment_name
}