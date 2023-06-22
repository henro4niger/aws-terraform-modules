variable "networks" {
  type = map(any)
  default = {
    rds = {
      subnets   = ["10.0.240.0/22", "10.0.244.0/22", "10.0.0.0/22"]
      is_public = true
    }
    ddb = {
      subnets   = ["10.0.12.0/22", "10.0.16.0/22", "10.0.20.0/22"]
      is_public = false
    }
  }
}

variable "env" {
  default = "dev"
}

variable "vpc_id" {

}

variable "subnet_name" {
  default = "default"
}
