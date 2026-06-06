resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "7.7.1"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

# Argo CD Application for bootstrapping the PetClinic app
resource "helm_release" "petclinic_bootstrap" {
  name       = "petclinic-bootstrap"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "1.6.2"

  depends_on = [helm_release.argocd]

  values = [
    <<-EOT
    applications:
      - name: petclinic-bootstrap
        namespace: argocd
        project: default
        source:
          repoURL: ${var.repo_url}
          targetRevision: gitops
          path: k8s/petclinic-chart

          helm:
            valueFiles:
              - values.yaml
            parameters:
              - name: image.repository
                value: "${var.image_repository}"
        destination:
          server: https://kubernetes.default.svc
          namespace: default
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
          syncOptions:
            - CreateNamespace=true
    EOT
  ]
}
