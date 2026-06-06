#!/bin/bash

# ==============================================================================
# Spring PetClinic EKS Infrastructure Destroyer
# ==============================================================================

set -e # Exit on error

REGION="eu-central-1"
CLUSTER_NAME="springpetclinic-eks"

echo "⚠️  WARNING: This will destroy ALL infrastructure for $CLUSTER_NAME"
echo "Starting destruction process in 5 seconds... (Ctrl+C to cancel)"
sleep 5

# 0. Connect to cluster
echo "🎡 Step 0: Connecting to Kubernetes Cluster..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME || echo "Could not update kubeconfig, cluster might already be gone."

# 1. Clean up Kubernetes resources (Crucial for LoadBalancer cleanup)
echo "🧹 Step 1: Cleaning up Kubernetes-managed resources..."

# Uninstall Nginx Ingress (to remove its AWS LoadBalancer)
echo "  - Uninstalling Nginx Ingress Controller..."
helm uninstall ingress-nginx -n ingress-nginx || echo "Ingress-nginx not found or already uninstalled."

# Delete the ECR secret
echo "  - Deleting ECR secret..."
kubectl delete secret ecr-secret || echo "Secret not found or already deleted."

# 2. Destroy Terraform Modules in Reverse Order
echo "🏗️ Step 2: Destroying Terraform Infrastructure..."

# Argo CD (Uninstall Argo CD and the bootstrap application)
echo "  - Destroying Argo CD Infrastructure..."
cd terraform/argocd
# We need to pass variables because they are required by the provider/data blocks
terraform destroy -auto-approve \
  -var "cluster_name=$CLUSTER_NAME" \
  -var "repo_url=https://github.com/mofayad96/spring-petclinic-Ci-CD.git" \
  -var "image_repository=dummy" 
cd ../..

# EKS
echo "  - Destroying EKS Cluster (this takes ~10-15 mins)..."
cd terraform/eks
# The variables are already in terraform.tfvars from the deploy script
terraform destroy -auto-approve
cd ../..

# IAM
echo "  - Destroying IAM Roles..."
cd terraform/iam
terraform destroy -auto-approve
cd ../..

# VPC
echo "  - Destroying VPC..."
cd terraform/vpc
terraform destroy -auto-approve
cd ../..

echo "=============================================================================="
echo "✅ Infrastructure Successfully Destroyed!"
echo "=============================================================================="
