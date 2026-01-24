variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
  description = "At least 2 AZs"
}

variable "public_subnet_cidrs" {
  type = list(string)
  description = "CIDRs for public subnets (same length as azs)"
}

variable "private_subnet_cidrs" {
  type = list(string)
  description = "CIDRs for private subnets (same length as azs)"
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}
