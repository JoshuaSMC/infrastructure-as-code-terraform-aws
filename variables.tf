variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "tasks-api"
}

variable "environment" {
  description = "Deployment environment (prod, staging)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["prod", "staging"], var.environment)
    error_message = "Environment must be 'prod' or 'staging'."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "container_image" {
  description = "Docker image to run. Leave empty to use the ECR repository created by this module (default). Set to a full image URI (e.g. ghcr.io/joshuasmc/tasks-api:latest) to override."
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Number of ECS task instances"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "CPU units for the ECS task (256 = 0.25 vCPU)"
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "memory" {
  description = "Memory in MB for the ECS task"
  type        = number
  default     = 512

  validation {
    condition     = contains([512, 1024, 2048, 4096, 8192, 16384], var.memory)
    error_message = "Memory must be one of: 512, 1024, 2048, 4096, 8192, 16384."
  }
}
