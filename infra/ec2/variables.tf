variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The AWS region to deploy the infrastructure into"
}

variable "owner" {
  type        = string
  default     = "distributed"
  description = "The owner name of the infrastructure"
}

variable "singlenode_multigpu_nvidia" {
  type        = bool
  default     = false
  description = "Whether to deploy NVIDIA G4dn.12xlarge instance node with 4x T4 GPUs"
}

variable "multinode_gpu_nvidia" {
  type        = bool
  default     = false
  description = "Whether to deploy multiple G4dn.xlarge Nvidia GPU instances with T4 GPU"
}

variable "singlenode_multigpu_amd" {
  type        = bool
  default     = false
  description = "Whether to deploy AMD G4dn.8xlarge instance node with 2x Radeon Pro V520 GPUs"
}

variable "multinode_gpu_amd" {
  type        = bool
  default     = false
  description = "Whether to deploy multiple G4ad.xlarge AMD GPU instances with Radeon Pro V520 GPU"
}

variable "multinode_standard" {
  type        = bool
  default     = false
  description = "Whether to deploy multiple standard T3.xlarge instances"
}

variable "multinode_mpi_launcher" {
  type        = bool
  default     = false
  description = "Whether to deploy MPI workload launcher T3.micro instance"
}

variable "custom_instance_nvidia_ami_override" {
  type        = string
  default     = ""
  description = "Custom AMI for NVIDIA G4dn instances"
}

variable "custom_instance_amd_ami_override" {
  type        = string
  default     = ""
  description = "Custom AMI for AMD G4ad instances"
}

