variable "aws_region" {
  description = "AWS region. AWS Academy Learner Lab is typically restricted to us-east-1 (vockey default key pair only exists there)."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Fixed prefix applied to every resource name/tag, so Repo 3 (RDS) can discover this repo's networking via data sources instead of manual copy-paste."
  type        = string
  default     = "tech-challenge"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "At least 2 AZs, required by EKS."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "cluster_name" {
  description = "Fixed, well-known name — Repo 3 references this same name via a data source to find the cluster's VPC/security group without needing this repo's Terraform state."
  type        = string
  default     = "tech-challenge-eks"
}

variable "kubernetes_version" {
  description = "Left empty on purpose: EKS deprecates old versions over time (1.29 stopped being creatable), so pinning one here would need updating periodically. An empty string lets AWS use its current default version automatically."
  type        = string
  default     = ""
}

variable "node_instance_type" {
  description = "Must be nano/micro/small/medium/large — the only sizes allowed on AWS Academy Learner Lab."
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  description = "Kept low on purpose: Learner Lab caps the whole account at 9 concurrent EC2 instances and 32 vCPUs; 20+ triggers account termination."
  type        = number
  default     = 2
}

variable "new_relic_license_key" {
  description = "New Relic ingest license key for the nri-bundle Kubernetes integration. Left empty until the New Relic instrumentation step — the helm_release is skipped while empty."
  type        = string
  sensitive   = true
  default     = ""
}
