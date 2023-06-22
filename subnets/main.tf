data "aws_region" "current_region" {}

locals {
  az_letter = ["a", "b", "c", "a", "b", "c"]
  az_number = [1, 2, 3, 4, 5, 6, 7]
  network_flat = flatten([
    for service, network in var.networks : [
      for app, address in network["subnets"] : [
        {
          az        = try(network["az"] == null, null) == null ? "${data.aws_region.current_region.name}${local.az_letter[app]}" : network["az"]
          az_num    = "${local.az_number[app]}"
          ip        = address
          id        = service
          is_public = network["is_public"]
        }
      ]
    ]
  ])
}

resource "aws_subnet" "subnet" {
  for_each                = { for net_info in local.network_flat : "${net_info.ip}:${net_info.id}" => net_info }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.ip
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.is_public
  tags = {
    Name        = var.subnet_name == "default" ? "moni-${var.env}-${each.value.is_public ? "public" : "private"}-sn${each.value.az_num}" : var.subnet_name
    Environment = "${var.env}"
  }
}
