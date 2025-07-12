variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "currency-converter-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.27"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "production"
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the cluster"
  type        = list(string)
}

# Node Group Variables
variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Instance type for the EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

# Application Variables
variable "docker_registry" {
  description = "Docker registry for the application image"
  type        = string
  default     = "123456789012.dkr.ecr.region.amazonaws.com"
}

variable "docker_image" {
  description = "Docker image name for the application"
  type        = string
  default     = "currency-converter"
}

variable "docker_image_tag" {
  description = "Docker image tag for the application"
  type        = string
  default     = "latest"
}

variable "exchange_rate_api_key" {
  description = "API key for the exchange rate service"
  type        = string
  sensitive   = true
}

# Autoscaling Variables
variable "min_replicas" {
  description = "Minimum number of pod replicas for HPA"
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum number of pod replicas for HPA"
  type        = number
  default     = 5
}