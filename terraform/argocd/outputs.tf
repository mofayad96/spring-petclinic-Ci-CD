output "argocd_server_url" {
  value = "Check kubectl get svc -n argocd argocd-server"
}

output "argocd_initial_admin_password" {
  value     = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  sensitive = true
}
