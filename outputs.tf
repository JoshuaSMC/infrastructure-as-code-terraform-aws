output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  value       = module.registry.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.container.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.container.service_name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.container.alb_dns_name
}

output "app_url" {
  description = "Public URL of the deployed application"
  value       = "http://${module.container.alb_dns_name}"
}
