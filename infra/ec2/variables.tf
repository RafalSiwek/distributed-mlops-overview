variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The AWS region to deploy the infrastructure into."
}

variable "owner" {
  type        = string
  default     = "distributed"
  description = "The owner name of the infrastructure."
}

variable "singlenode_multigpu" {
  type        = bool
  default     = false
  description = "Whether to deploy instances with a single node with multiple GPUs."
}

variable "multinode_gpu" {
  type        = bool
  default     = false
  description = "Whether to deploy multiple G4dn Nvidia GPU instances."
}

variable "multinode_gpu_amd" {
  type        = bool
  default     = false
  description = "Whether to deploy multiple G4ad AMD GPU instances."
}

variable "multinode" {
  type        = bool
  default     = false
  description = "Whether to deploy multiple standard instances."
}

variable "multinode_mpi" {
  type        = bool
  default     = false
  description = "Whether to deploy multiple micro instances for MPI workload."
}
