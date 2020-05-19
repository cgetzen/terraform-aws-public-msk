## Confirm that the ENI's are a part of a subnet with an IGW

data "aws_network_interface" "network_interface" {
  for_each = var.check_errors ? data.aws_network_interfaces.network_interfaces : {}
  id       = tolist(each.value.ids)[0]
}

data "aws_route_table" "route_table" {
  for_each  = var.check_errors ? data.aws_network_interface.network_interface : {}
  subnet_id = each.value.subnet_id
}

data "aws_route" "route" {
  for_each               = var.check_errors ? data.aws_route_table.route_table : {}
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
}

locals {
  no_igw_errors = [for route in data.aws_route.route : regex("igw-[a-z]*", route.gateway_id)]
}
