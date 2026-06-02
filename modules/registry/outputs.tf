output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.main.name
}

output "registry_id" {
  description = "ECR registry ID (AWS account ID)"
  value       = aws_ecr_repository.main.registry_id
}
