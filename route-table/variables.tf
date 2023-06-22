variable "routes" {
  type = map(any)
  default = {
    route1 = {
      "route" = ["0.0.0.0/0", "internet_gw"]
    }
    route2 = {
      "route" = ["192.168.0.0/0", "transit_gw"]
    }
    route3 = {
      "route" = ["1.2.3.4/32", "nat_gw"]
    }
  }
}

variable "gateways" {
  type    = list(string)
  default = ["i-skfkdj:transit_gw", "vg-i9iui:nat_gw"]
}

variable "env" {
  default = "dev"
}

variable "service" {

}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet_list"]

}

variable "vpc_id" {

}

variable "is_public" {
  default = false

}

variable "route_table_name" {
  default = "default"
}
