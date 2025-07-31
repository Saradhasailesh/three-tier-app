
variable "private_subnet_cidrs" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ingress_ports" {
  type = list(number)
  default = [22, 80]
}