variable "security_group_ids" {
  type = string
}

variable "public_subnet_id" {
  type = list(string)
}

variable "app_server_ids" {
  type = list(string)
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}