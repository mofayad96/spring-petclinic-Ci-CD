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
        goTemplate: true
        generators:
          - list:
              elements:
                - env: dev
                  namespace: dev
                  valuesFile: values-dev.yaml
                - env: staging
                  namespace: staging
                  valuesFile: values-staging.yaml
                - env: prod
                  namespace: prod
                  valuesFile: values-prod.yaml
        template:
          metadata:
            name: "petclinic-{{.env}}"
          spec:
            project: default
            source:
              repoURL: ${var.repo_url}
              targetRevision: gitops
              path: k8s/petclinic-chart
              helm:
                valueFiles:
                  - values.yaml
                  - "{{.valuesFile}}"
                parameters:
                  - name: image.repository
                    value: "${var.image_repository}"
            destination:
              server: https://kubernetes.default.svc
              namespace: "{{.namespace}}"
            syncPolicy:
              syncOptions:
                - CreateNamespace=true
        templatePatch: |
          {{- if ne .env "prod" }}
          spec:
            syncPolicy:
              automated:
                prune: true
                selfHeal: true
          {{- end }}
    EOT
  ]
}

resource "kubernetes_namespace" "argo_rollouts" {
  metadata {
    name = "argo-rollouts"
  }
}

resource "helm_release" "argo_rollouts" {
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = kubernetes_namespace.argo_rollouts.metadata[0].name
  version    = "2.41.0"

  set {
    name  = "dashboard.enabled"
    value = "true"
  }
}

