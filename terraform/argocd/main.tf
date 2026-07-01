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

# Argo CD ApplicationSet for multi-environment deployment (dev, staging, prod)
resource "helm_release" "petclinic_environments" {
  name       = "petclinic-environments"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "1.6.2"

  depends_on = [helm_release.argocd]

  values = [
    <<-EOT
    applicationsets:
      - name: petclinic-environments
        namespace: argocd
        generators:
          - list:
              elements:
                - env: dev
                  namespace: dev
                  valuesFile: values-dev.yaml
                  autoSync: "true"
                - env: staging
                  namespace: staging
                  valuesFile: values-staging.yaml
                  autoSync: "true"
                - env: prod
                  namespace: prod
                  valuesFile: values-prod.yaml
                  autoSync: "false"
        template:
          metadata:
            name: "petclinic-{{env}}"
          spec:
            project: default
            source:
              repoURL: ${var.repo_url}
              targetRevision: gitops
              path: k8s/petclinic-chart
              helm:
                valueFiles:
                  - values.yaml
                  - "{{valuesFile}}"
                parameters:
                  - name: image.repository
                    value: "${var.image_repository}"
            destination:
              server: https://kubernetes.default.svc
              namespace: "{{namespace}}"
            syncPolicy:
              syncOptions:
                - CreateNamespace=true
    EOT
  ]
}

