variable "nacl_rules" {
  type = map(any)
  default = {
    rule1 = {
      "rule" = ["allow", "ip", "from", "to", "protocol", "rule_number", "rule_dir"]
    }
    rule2 = {
      "rule" = ["allow", "ip", "from", "to", "protocol", "rule_number", "rule_dir"]
    }
  }
}


variable "env" {
  default = "dev"
}

variable "vpc_id" {
}


variable "subnet_ids" {
}
