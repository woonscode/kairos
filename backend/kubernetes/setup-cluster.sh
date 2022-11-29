#!/bin/bash

set -e

# Removed Account ID for security reaons
region="ap-southeast-1"
account_id="1234567890"
registry_url="$account_id.dkr.ecr.$region.amazonaws.com" # 1234567890.dkr.ecr.ap-southeast-1.amazonaws.com

# Input credentials for AWS to be used with AWS CLI and kubectl
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""

# Update kubectl kubeconfig through AWS CLI - need to clear current local machine kubeconfig file as it is a little buggy
aws eks update-kubeconfig --name "kairos"

# Create namespace
kubectl create namespace "kairos"

# Create secret for container images to use to authenticate to private registry - not crucial as ecr-token-refresher CronJob will create this secret too (must supply credentials in the CronJob manifest in ecr-token-refresher.yml)
kubectl create secret docker-registry "ecr-credentials" \
  --docker-server="$registry_url" \
  --docker-username="AWS" \
  --docker-password=$(aws ecr get-login-password) \
  --namespace="kairos"

kubectl apply -f "./manifests/main-app"

# Install ALB Controller from Helm chart
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="kairos" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set image.repository=602401143452.dkr.ecr.ap-southeast-1.amazonaws.com/amazon/aws-load-balancer-controller

# Deploy Metrics Server pre-req for Kubernetes Dashboard
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Deploy Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml

# Deploy Prometheus + Grafana + AlertManager
kubectl apply --server-side -f "./manifests/kube-prometheus/setup"
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f "./manifests/kube-prometheus/"

# # Uninstall AWS Load Balancer Controller + Prometheus + Grafana + AlertManager
# kubectl delete ingress/kairos-ingress -n kairos
# helm uninstall aws-load-balancer-controller -n kube-system
# kubectl delete --ignore-not-found=true -f "./manifests/kube-prometheus/" -f "./manifests/kube-prometheus/setup"