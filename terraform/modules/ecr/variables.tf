variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "keep_last_images" {
  type    = number
  default = 20
}