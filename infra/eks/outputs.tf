output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${local.resource_prefix}"
}

output "grafana_secret_name" {
  description = "The name of the secret containing the Grafana admin password."
  value       = aws_secretsmanager_secret.grafana.name
}

output "expose_dashboard" {
  description = "Guide to expose the kubernetes dasboard"
  value = tostring(<<-EOF
    # Expose the dashboard over kubectl proxy to localhost:8443:
    kubectl port-forward service/kubernetes-dashboard-kong-proxy -n kubernetes-dashboard 8443:443
    # Access the dashboard under unsafe https://localhost:8443 - no cert
    # Generate dashboard token:
    aws eks get-token --cluster-name ${local.resource_prefix} --region ${var.region}
  EOF
  )
}
