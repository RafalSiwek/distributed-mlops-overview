#---------------------------------------------------------------
# Nvidia GPU operator
#---------------------------------------------------------------

resource "helm_release" "nvidia_gpu_operator" {
  count            = var.training_job_multinode_gpu_enabled ? 1 : 0
  namespace        = "nvidia-gpu-operator"
  name             = "nvidia-gpu-operator"
  create_namespace = true
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "gpu-operator"
  version          = "v24.9.1"
  values           = [templatefile("${path.module}/helm_values/nvidia-gpu-operator-values.yaml", {})]

  depends_on = [
    module.eks_blueprints_addons
  ]
}


#---------------------------------------------------------------
# AMD ROCm GPU operator
#---------------------------------------------------------------

# At this moment the AMD GPU Operator does not support configuring taints, so we only use deploy the Device Plugin

# resource "helm_release" "cert_manager" {
#   namespace        = "cert-manager"
#   name             = "cert-manager"
#   create_namespace = true
#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   version          = "v1.15.1"

#   set {
#     name  = "crds.enabled"
#     value = true
#   }


#   depends_on = [
#     module.eks_blueprints_addons
#   ]
# }

# resource "helm_release" "amd_gpu_operator" {
#   namespace        = "amd-gpu-operator"
#   name             = "amd-gpu-operator"
#   create_namespace = true
#   repository       = "https://rocm.github.io/gpu-operator"
#   chart            = "gpu-operator-charts"
#   version          = "v1.0.0"
#   values           = [templatefile("${path.module}/helm_values/amd-gpu-operator-values.yaml", {})]

#   depends_on = [
#     module.eks_blueprints_addons,
#     helm_release.cert_manager,
#     helm_release.amd_device_plugin,
#   ]
# }

resource "helm_release" "amd_device_plugin" {
  count            = var.training_job_multinode_gpu_enabled ? 1 : 0
  namespace        = "amd-gpu-operator"
  name             = "amd-gpu-plugin"
  create_namespace = true
  repository       = "https://rocm.github.io/k8s-device-plugin"
  chart            = "amd-gpu"
  version          = "v0.16.0"
  values           = [templatefile("${path.module}/helm_values/amd-gpu-device-plugin-values.yaml", {})]


  depends_on = [
    module.eks_blueprints_addons
  ]
}
