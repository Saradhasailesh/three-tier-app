variable "security_group_ids" {
  type = list(string)
}


variable "private_subnet_id" {
  type = list(string)
}

variable "public_subnet_id" {
  type = list(string)
}

variable "region" {
  type = string

}
variable "key_name" {
  type = string
}

variable "public_key" {
  type = string

}

variable "instance_type" {
  description = "defines the cpu,RAM allotted for the ec2_instance"
  type        = string
}

variable "ami" {
  description = "this represent the base OS and its version"
  type        = string
}

