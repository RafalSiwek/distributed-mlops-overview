#---------------------------------------------------------------
# GP3 Encrypted Storage Class
#---------------------------------------------------------------
resource "kubernetes_annotations" "disable_gp2" {
  annotations = {
    "storageclass.kubernetes.io/is-default-class" : "false"
  }
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  force = true

  depends_on = [
    module.eks.eks_cluster_id
  ]
}

resource "kubernetes_storage_class" "default_gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" : "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    fsType    = "ext4"
    encrypted = true
    type      = "gp3"
  }

  depends_on = [
    kubernetes_annotations.disable_gp2
  ]
}

#---------------------------------------------------------------
# IRSA for EBS CSI Driver
#---------------------------------------------------------------
module "ebs_csi_driver_irsa" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "~> 5.20"
  role_name_prefix      = format("%s-%s-", local.resource_prefix, "ebs-csi-driver")
  attach_ebs_csi_policy = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  tags = local.common_tags
}

#---------------------------------------------------------------
# EKS Blueprints Addons
#---------------------------------------------------------------
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.19"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  #---------------------------------------
  # Amazon EKS Managed Add-ons
  #---------------------------------------
  eks_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  #---------------------------------------
  # AWS Load Balancer Controller Add-on
  #---------------------------------------
  enable_aws_load_balancer_controller = true
  # turn off the mutating webhook for services because we are using
  # service.beta.kubernetes.io/aws-load-balancer-type: external
  aws_load_balancer_controller = {
    set = [{
      name  = "enableServiceMutatorWebhook"
      value = "false"
    }]
  }

  #---------------------------------------
  # Ingress Nginx Add-on
  #---------------------------------------
  enable_ingress_nginx = true
  ingress_nginx = {
    values = [templatefile("${path.module}/helm_values/ingress-nginx-values.yaml", {})]
  }

  #---------------------------------------
  # Karpenter Autoscaler for EKS Cluster
  #---------------------------------------
  enable_karpenter                  = true
  karpenter_enable_spot_termination = true
  karpenter_node = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
  karpenter = {
    chart_version       = "1.1.0"
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
    source_policy_documents = [
      data.aws_iam_policy_document.karpenter_controller_policy.json
    ]
  }

  #---------------------------------------
  # Prommetheus and Grafana stack
  #---------------------------------------
  #---------------------------------------------------------------
  # 1- Grafana port-forward `kubectl port-forward svc/kube-prometheus-stack-grafana 8080:80 -n kube-prometheus-stack`
  # 2- Grafana Admin user: admin
  # 3- Get sexret name from Terrafrom output: `terraform output grafana_secret_name`
  # 3- Get admin user password: `aws secretsmanager get-secret-value --secret-id <REPLACE_WIRTH_SECRET_ID> --region $AWS_REGION --query "SecretString" --output text`
  #---------------------------------------------------------------
  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    values = [
      templatefile("${path.module}/helm_values/kube-prometheus.yaml", {
        storage_class_type = kubernetes_storage_class.default_gp3.id
      })
    ]
    chart_version = "48.1.1"
    set_sensitive = [
      {
        name  = "grafana.adminPassword"
        value = data.aws_secretsmanager_secret_version.admin_password_version.secret_string
      }
    ],
  }

}


#---------------------------------------------------------------
# Grafana Admin credentials resources
# Login to AWS secrets manager with the same role as Terraform to extract the Grafana admin password with the secret name as "grafana"
#---------------------------------------------------------------
data "aws_secretsmanager_secret_version" "admin_password_version" {
  secret_id  = aws_secretsmanager_secret.grafana.id
  depends_on = [aws_secretsmanager_secret_version.grafana]
}

resource "random_password" "grafana" {
  length           = 16
  special          = true
  override_special = "@_"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "grafana" {
  name_prefix             = "${local.resource_prefix}-oss-grafana"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "grafana" {
  secret_id     = aws_secretsmanager_secret.grafana.id
  secret_string = random_password.grafana.result
}

data "aws_iam_policy_document" "karpenter_controller_policy" {
  statement {
    actions = [
      "ec2:RunInstances",
      "ec2:CreateLaunchTemplate",
    ]
    resources = ["*"]
    effect    = "Allow"
    sid       = "KarpenterControllerAdditionalPolicy"
  }
}

#---------------------------------------------------------------
# Kubernetes Dashboard
#---------------------------------------------------------------
#---------------------------------------------------------------
# For demo purposes dashboard deployemnt is done in a simple vanilla config, with auth done over geberated token
# 1- Dashboard port-forward `kubectl port-forward service/kubernetes-dashboard-kong-proxy -n kubernetes-dashboard 8443:443`
# 2- Access dashboard under https://localhost:8443
# 2- Dashboard auth token: `aws eks get-token --cluster-name <REPLACE_WITH_CLUSTER_NAME> --region <REPLACE_WITH_REGION>` --query "SecretString" --output text`
#---------------------------------------------------------------
resource "helm_release" "kubernetes_dashboard" {
  namespace        = "kubernetes-dashboard"
  create_namespace = true
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  version          = "7.10.1"
  depends_on = [
    module.eks_blueprints_addons
  ]
}

#---------------------------------------------------------------
# Data on EKS Kubernetes Addons
#---------------------------------------------------------------

module "data_addons" {
  source  = "aws-ia/eks-data-addons/aws"
  version = "1.35.0"

  oidc_provider_arn = module.eks.oidc_provider_arn

  #---------------------------------------------------------------
  # Kubecost Add-on
  #---------------------------------------------------------------
  enable_kubecost = true
  kubecost_helm_config = {
    values              = [templatefile("${path.module}/helm_values/kubecost-values.yaml", {})]
    version             = "2.2.2"
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
  }

  #---------------------------------------------------------------
  # Volcano Scheduler Add-on
  #---------------------------------------------------------------
  enable_volcano = var.volcano_scheduler_enabled
  volcano_helm_config = {
    version = "1.10.0"
  }

  #---------------------------------------
  # Kuberay Operator
  #---------------------------------------
  enable_kuberay_operator = var.ray_cluster_enabled
  kuberay_operator_helm_config = {
    version = "1.2.2"
    # Enabling Volcano as Batch scheduler for KubeRay Operator
    values = [
      <<-EOT
      batchScheduler:
        enabled: true
    EOT
    ]
  }

  depends_on = [
    module.eks_blueprints_addons
  ]
}
