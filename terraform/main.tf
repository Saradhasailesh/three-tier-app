provider "aws" {
  region = var.region

}

module "vpc" {
  source = "./modules/vpc/"
  region = var.region
}

module "loadbalancer" {
  source             = "./modules/loadbalancer"
  region             = var.region
  security_group_ids = module.vpc.allow_http
  public_subnet_id   = module.vpc.public_subnet_id
  app_server_ids     = module.ec2.app_server_ids
  vpc_id             = module.vpc.vpc_id

}

module "ec2" { 
  source             = "./modules/ec2"
  ami                = var.ami
  region             = var.region
  instance_type      = var.instance_type
  key_name           = var.key_name
  public_key         = var.public_key
  private_subnet_id  = module.vpc.private_subnet_id
  public_subnet_id   = module.vpc.public_subnet_id
  security_group_ids = [module.vpc.allow_http, module.vpc.allow_http_ssh, module.vpc.allow_ssh]
  depends_on = [module.vpc]
}

