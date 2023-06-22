variable "rules" {
  type = map(any)
  default = {
    "rule1 description" = {
      from_port          = "80"
      to_port            = "80"
      protocol           = "tcp"
      allowed_cidr_block = "0.0.0.0/0"
    },
    "rule2 description" = {
      from_port          = "443"
      to_port            = "443"
      protocol           = "tcp"
      allowed_cidr_block = "0.0.0.0/0"
    }
  }
}



variable "env" {
  default = "production"
}

variable "service_name" {
}

variable "vpc_id" {

}

variable "description" {
  default = "managed with terraform"
}
