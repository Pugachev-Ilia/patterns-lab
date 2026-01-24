variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "enable_container_insights" {
  type    = bool
  default = true
}

