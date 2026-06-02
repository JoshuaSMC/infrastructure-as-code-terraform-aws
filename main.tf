terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  container_port     = var.container_port
}

module "registry" {
  source = "./modules/registry"

  project_name = var.project_name
  environment  = var.environment
}

module "container" {
  source = "./modules/container"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
  ecs_security_group_id = module.networking.ecs_security_group_id
  container_image       = var.container_image != "" ? var.container_image : module.registry.repository_url
  container_port     = var.container_port
  desired_count      = var.desired_count
  cpu                = var.cpu
  memory             = var.memory

  depends_on = [module.networking, module.registry]
}
