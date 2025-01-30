variable "region" {
  description = "Region"
  type        = string
  default     = "eu-west-1"
}

variable "owner" {
  type        = string
  default     = "distributed"
  description = <<-EOF
    The owner name of the infrastructure.
EOF
}

variable "eks_cluster_version" {
  description = "EKS Cluster version"
  default     = "1.31"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR. This should be a valid private (RFC 1918) CIDR range"
  default     = "10.1.0.0/21"
  type        = string
}

variable "secondary_cidr_blocks" {
  description = "Secondary CIDR blocks to be attached to VPC"
  default     = ["100.64.0.0/16"]
  type        = list(string)
}

variable "training_job_multinode_gpu_enabled" {
  type    = bool
  default = false
}

variable "training_job_multinode_enabled" {
  type    = bool
  default = false
}

variable "ray_cluster_enabled" {
  type    = bool
  default = false
}

variable "volcano_scheduler_enabled" {
  type    = bool
  default = true
}
