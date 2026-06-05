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
# Handle existing ECR repo
terraform import aws_ecr_repository.repo springpetclinic || true
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

# 3. Application Deployment
echo "📦 Step 3: Deploying PetClinic Application..."
cd k8s/petclinic-chart
helm upgrade --install petclinic . \
  --set image.repository=$ECR_URL \
  --set image.tag=latest
cd ../..

echo "=============================================================================="
echo "✅ Deployment Complete!"
echo "📍 Access your app at:"
kubectl get ingress petclinic-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
echo "=============================================================================="
