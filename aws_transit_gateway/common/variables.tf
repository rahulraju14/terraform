variable "transit_gateway_name" {
  type = string
  default = "tf_transit_gateway"
}

variable "transit_gateway_attachment_name" {
  type = string
  default = "transit_gateway_attachment"
}

variable "vpc_id" {
  type = string
  default = ""

   validation {
    condition = var.vpc_id != ""
    error_message = "Vpc id is required"
  }
}

variable "transit_gateway_id" {
  type = string
  default = ""

  validation {
    condition = var.transit_gateway_id != ""
    error_message = "Transit gateway id is required"
  }
}

variable "subnet_ids" {
  type = list(string)
  default = [""]

   validation {    
    condition     = length(var.subnet_ids) > 1    
    error_message = "Subnet id's reference must contain atleast one subnet to assosicate with vpc"  
    }
}

output "transit_gateway_attachment_name" {
  value = var.transit_gateway_attachment_name
}

output "transit_gateway_name" {
  value = var.transit_gateway_name
}

output "vpc_id" {
  value = var.vpc_id
}

output "transit_gateway_id" {
  value = var.transit_gateway_id
}

output "subnet_ids" {
  value = var.subnet_ids
}