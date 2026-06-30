#!/bin/bash

# ==============================================================================
# Spring PetClinic EKS Deployment Automator
# ==============================================================================

set -e # Exit on error

# --- sConfiguration ---
REGION="eu-central-1"
CLUSTER_NAME="springpetclinic-eks"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/springpetclinic"

echo "🚀 Starting Deployment for Account: $ACCOUNT_ID in $REGION"

# 1. Terraform Infrastructure
echo "🏗️ Step 1: Provisioning Infrastructure with Terraform..."

# VPC
echo "  - Provisioning VPC..."
cd terraform/vpc
terraform init && terraform apply -auto-approve
PRIVATE_SUBNETS=$(terraform output -json private_subnet_ids | jq -r '.[]' | tr '\n' ',' | sed 's/,$//')
cd ../..

# IAM
echo "  - Provisioning IAM Roles..."
cd terraform/iam
terraform init && terraform apply -auto-approve
CLUSTER_ROLE=$(terraform output -raw eks_cluster_role_arn)
NODE_ROLE=$(terraform output -raw eks_node_role_arn)
cd ../..

# EKS
echo "  - Provisioning EKS Cluster (this takes ~15-20 mins)..."
cd terraform/eks
# Prepare tfvars dynamically
cat <<EOF > terraform.tfvars
cluster_role_arn   = "$CLUSTER_ROLE"
node_role_arn      = "$NODE_ROLE"
private_subnet_ids = [$(echo $PRIVATE_SUBNETS | sed 's/[^, ]*/"&"/g')]
cluster_name       = "$CLUSTER_NAME"
EOF

terraform init
terraform apply -auto-approve
cd ../..

# Argo CD
echo "  - Provisioning Argo CD and Bootstrap Application..."
cd terraform/argocd
cat <<EOF > terraform.tfvars
cluster_name     = "$CLUSTER_NAME"
region           = "$REGION"
repo_url         = "https://github.com/mofayad96/spring-petclinic-Ci-CD.git"
image_repository = "$ECR_URL"
EOF

terraform init
terraform apply -auto-approve
cd ../..

# 2. Kubernetes Configuration
echo "🎡 Step 2: Configuring Kubernetes..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# ECR Secret
echo "  - Creating ECR Pull Secret..."
kubectl create secret docker-registry ecr-secret \
  --docker-server=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region $REGION) \
  --dry-run=client -o yaml | kubectl apply -f -

# Ingress Controller
echo "  - Installing Nginx Ingress Controller..."
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

echo "  - Waiting for Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# 3. Monitoring Stack (Prometheus + Grafana)
echo "📊 Step 3: Installing Monitoring Stack..."
helm upgrade --install kube-prometheus-stack kube-prometheus-stack \
  --repo https://prometheus-community.github.io/helm-charts \
  --namespace monitoring --create-namespace \
  -f monitoring/values.yaml \
  --wait --timeout 5m

echo "  - Applying Grafana dashboard and Prometheus rules..."
kubectl apply -f monitoring/grafana-dashboard-configmap.yaml
kubectl apply -f monitoring/prometheus-rules.yaml
kubectl apply -f monitoring/petclinic-service-monitor.yaml

# 4. Application Deployment
echo "📦 Step 4: Deploying PetClinic Application (Managed by Argo CD)..."

echo "=============================================================================="
echo "✅ Deployment Complete!"
echo "📍 Access your app at:"
kubectl get ingress petclinic-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
echo "=============================================================================="
