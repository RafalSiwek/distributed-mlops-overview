#---------------------------------------------------------------------------
# Custom Karpenter-provisioned Ubuntu Node Class
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# Provisions an Ubuntu-AMI based Node Class 
# See https://karpenter.sh/docs/concepts/nodeclasses/#specamifamily
#---------------------------------------------------------------------------

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = local.nodeclass_name
    }
    spec = {
      amiFamily = "Custom"
      amiSelectorTerms = [
        {
          id = data.aws_ami.ubuntu.id
        }
      ]
      role = module.eks_blueprints_addons.karpenter.node_iam_role_name
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = local.resource_prefix
          }
        }
      ]

      securityGroupSelectorTerms = [
        {
          id = module.eks.node_security_group_id
        }
      ]
      tags = {
        "karpenter.sh/discovery" = local.resource_prefix
      }
      detailedMonitoring = true
      blockDeviceMappings = [
        {
          deviceName = "/dev/sda1"
          rootVolume = true
          ebs = {
            volumeSize = "300Gi"
            volumeType = "gp3"
          }
        }
      ]
      userData = base64encode(
        <<-EOT
          #!/bin/bash
          echo "$(jq '. += {"registerWithTaints": [{"key": "karpenter.sh/unregistered", "effect": "NoExecute"}]}' /etc/kubernetes/kubelet/kubelet-config.json)" > /etc/kubernetes/kubelet/kubelet-config.json
          /etc/eks/bootstrap.sh ${local.resource_prefix}
      EOT
      )
    }
  })
}

#---------------------------------------------------------------------------
# Standard Training Operator NodePool - m5
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# Used for standard training operator jobs
#---------------------------------------------------------------------------

resource "kubectl_manifest" "training_operator_job_nodepool" {
  count = var.training_job_multinode_enabled ? 1 : 0
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "training-operator-job"
    }
    spec = {
      template = {
        metadata = {
          labels = {
            type          = "karpenter"
            NodeGroupType = "training-operator-job"
          }
        }
        spec = {
          expireAfter = "10h"
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = local.nodeclass_name
          }

          taints = [
            {
              key    = "training-operator-job"
              effect = "NoSchedule"
            }
          ]

          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"]
            },
            {
              key      = "karpenter.k8s.aws/instance-family"
              operator = "In"
              values   = ["m5"]
            },

            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "In"
              values   = ["xlarge"]
            }
          ]
        }
        limits = {
          "cpu" = 1000
        }
      }
    }
  })
  depends_on = [kubectl_manifest.karpenter_node_template]
}

#---------------------------------------------------------------------------
# NVIDIA GPU Training Operator NodePool - G4dn
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# Used for NVIDIA T4 GPU accelerated training operator jobs
# See https://aws.amazon.com/ec2/instance-types/g4/
#---------------------------------------------------------------------------

resource "kubectl_manifest" "training_operator_job_nvidia_gpu_nodepool" {
  count = var.training_job_multinode_gpu_enabled ? 1 : 0
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "training-operator-job-nvidia-gpu"
    }
    spec = {
      template = {
        metadata = {
          labels = {
            type          = "karpenter"
            NodeGroupType = "training-operator-job-nvidia-gpu"
          }
        }
        spec = {
          expireAfter = "10h"
          disruption = {
            consolidationPolicy = "WhenEmptyOrUnderutilized"
            consolidateAfter    = "20m"
          }
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = local.nodeclass_name
          }

          taints = [
            {
              key      = "nvidia.com/gpu"
              operator = "Exists"
              effect   = "NoSchedule"
            },
            {
              key    = "training-operator-job-gpu"
              effect = "NoSchedule"
            }
          ]

          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"]
            },
            {
              key      = "karpenter.k8s.aws/instance-family"
              operator = "In"
              values   = ["g4dn"]
            },
            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "In"
              values   = ["xlarge"]
            }
          ]
        }
        limits = {
          "nvidia.com/gpu" = 2
        }
      }
    }
  })
  depends_on = [kubectl_manifest.karpenter_node_template]
}

#---------------------------------------------------------------------------
# Ray Cluster Head Standard NodePool - m5
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# Used for hosting the head of Ray Cluster
#---------------------------------------------------------------------------

resource "kubectl_manifest" "raycluster_nodepool_head" {
  count = var.ray_cluster_enabled ? 1 : 0
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "ray-cluster-head"
    }
    spec = {
      template = {
        metadata = {
          labels = {
            type          = "karpenter"
            NodeGroupType = "ray-cluster-head"
          }
        }
        spec = {
          expireAfter = "10h"
          disruption = {
            consolidationPolicy = "WhenEmpty"
            consolidateAfter    = "20m"
          }
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = local.nodeclass_name
          }

          taints = [
            {
              key    = "ray-cluster-head"
              effect = "NoSchedule"
            }
          ]

          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"]
            },
            {
              key      = "karpenter.k8s.aws/instance-family"
              operator = "In"
              values   = ["m5"]
            },
            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "In"
              values   = ["xlarge", "2xlarge", "4xlarge"]
            }
          ]
        }
        limits = {
          cpu = 1000
        }
      }
    }
  })
  depends_on = [kubectl_manifest.karpenter_node_template]
}

#---------------------------------------------------------------------------
# Ray Cluster Worker Standard NodePool - m5
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# Used to provision the workers for Ray Cluster Jobs
#---------------------------------------------------------------------------

resource "kubectl_manifest" "raycluster_cpu_nodepool_worker" {
  count = var.ray_cluster_enabled ? 1 : 0
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "ray-cluster-worker"
    }
    spec = {
      template = {
        metadata = {
          labels = {
            type          = "karpenter"
            NodeGroupType = "ray-cluster-worker"
          }
        }
        spec = {
          expireAfter = "10h"
          disruption = {
            consolidationPolicy = "WhenEmptyOrUnderutilized"
            consolidateAfter    = "30s"
          }
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = local.nodeclass_name
          }

          taints = [
            {
              key    = "ray-cluster-worker"
              effect = "NoSchedule"
            }
          ]

          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"]
            },
            {
              key      = "karpenter.k8s.aws/instance-family"
              operator = "In"
              values   = ["m5"]
            },
            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "In"
              values   = ["large", "xlarge", "2xlarge"]
            }
          ]
        }
        limits = {
          cpu = 1000
        }
      }
    }
  })
  depends_on = [kubectl_manifest.karpenter_node_template]
}

#---------------------------------------------------------------------------
# AMD GPU NodePool - G4ad
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# For AMD GPUs, at this point in time, AWS only supports EC2 G4ad instances, 
# powered by AMD Radeon Pro V520 GPUs. See: https://aws.amazon.com/ec2/amd/
# 
# Because of non-trivial, in-cluster driver management, we use a custom AMI
# with ROCm 6.2.2 installed
#---------------------------------------------------------------------------

resource "kubectl_manifest" "karpenter_amd_gpu_node_template" {
  count = var.training_job_multinode_gpu_enabled ? 1 : 0
  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "${local.nodeclass_name}-amd-gpu"
    }
    spec = {
      amiFamily = "Custom"
      amiSelectorTerms = [
        {
          id = "ami-05906beda0daa6980"
        }
      ]
      role = module.eks_blueprints_addons.karpenter.node_iam_role_name
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = local.resource_prefix
          }
        }
      ]

      securityGroupSelectorTerms = [
        {
          id = module.eks.node_security_group_id
        }
      ]
      tags = {
        "karpenter.sh/discovery" = local.resource_prefix
      }
      detailedMonitoring = true
      blockDeviceMappings = [
        {
          deviceName = "/dev/sda1"
          rootVolume = true
          ebs = {
            volumeSize = "300Gi"
            volumeType = "gp3"
          }
        }
      ]
      userData = base64encode(
        <<-EOT
          #!/bin/bash
          echo "$(jq '. += {"registerWithTaints": [{"key": "karpenter.sh/unregistered", "effect": "NoExecute"}]}' /etc/kubernetes/kubelet/kubelet-config.json)" > /etc/kubernetes/kubelet/kubelet-config.json
          /etc/eks/bootstrap.sh ${local.resource_prefix}
      EOT
      )
    }
  })
}


resource "kubectl_manifest" "training_operator_job_amd_gpu_nodepool" {
  count = var.training_job_multinode_gpu_enabled ? 1 : 0
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "training-operator-job-amd-gpu"
    }
    spec = {
      template = {
        metadata = {
          labels = {
            type          = "karpenter"
            NodeGroupType = "training-operator-job-amd-gpu"
          }
        }
        spec = {
          expireAfter = "10h"
          disruption = {
            consolidationPolicy = "WhenEmptyOrUnderutilized"
            consolidateAfter    = "20m"
          }
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "${local.nodeclass_name}-amd-gpu"
          }

          taints = [
            {
              key      = "amd.com/gpu"
              operator = "Exists"
              effect   = "NoSchedule"
            },
            {
              key    = "training-operator-job-gpu"
              effect = "NoSchedule"
            }
          ]

          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"]
            },
            {
              key      = "karpenter.k8s.aws/instance-family"
              operator = "In"
              values   = ["g4ad"]
            },
            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "In"
              values   = ["xlarge", "2xlarge", "4xlarge"]
            }
          ]
        }
        limits = {
          "amd.com/gpu" = 2
        }
      }
    }
  })
  depends_on = [kubectl_manifest.karpenter_amd_gpu_node_template]
}
