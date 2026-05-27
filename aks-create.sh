#!/bin/bash
# ─── Restauranty – Create AKS Cluster ────────────────────────────────────────
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - kubectl installed
#   - helm installed
#
# Usage:
#   chmod +x aks-create.sh
#   ./aks-create.sh
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
SUBSCRIPTION_ID="daf9c53c-7096-4293-9bb1-f7ad8263db1a"
RESOURCE_GROUP="geraldAKSGroup"
CLUSTER_NAME="geraldAKSCluster"
LOCATION="eastus"
NODE_COUNT=2
NODE_VM_SIZE="Standard_B2s"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Restauranty – AKS Cluster Setup"
echo " Subscription  : $SUBSCRIPTION_ID"
echo " Resource Group: $RESOURCE_GROUP"
echo " Cluster       : $CLUSTER_NAME"
echo " Location      : $LOCATION"
echo " Nodes         : $NODE_COUNT x $NODE_VM_SIZE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Set subscription ──────────────────────────────────────────────────────────
echo ""
echo "▶ Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"
echo "✔ Subscription set"

# ── Create resource group ─────────────────────────────────────────────────────
echo ""
echo "▶ Creating resource group '$RESOURCE_GROUP' in '$LOCATION'..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output table
echo "✔ Resource group ready"

# ── Pick latest stable Kubernetes version ─────────────────────────────────────
echo ""
echo "▶ Fetching latest stable Kubernetes version..."
K8S_VERSION=$(az aks get-versions --location "$LOCATION" \
  --query "values[?isPreview==null].version | sort(@) | [-1]" \
  --output tsv)
echo "✔ Using Kubernetes version: $K8S_VERSION"

# ── Create AKS cluster ────────────────────────────────────────────────────────
echo ""
echo "▶ Creating AKS cluster '$CLUSTER_NAME' (this takes ~5 minutes)..."
az aks create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --node-count "$NODE_COUNT" \
  --node-vm-size "$NODE_VM_SIZE" \
  --kubernetes-version "$K8S_VERSION" \
  --enable-managed-identity \
  --location "$LOCATION" \
  --generate-ssh-keys \
  --output table
echo "✔ Cluster created"

# ── Get credentials ───────────────────────────────────────────────────────────
echo ""
echo "▶ Fetching cluster credentials..."
az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --overwrite-existing
echo "✔ kubectl configured"

# ── Install NGINX Ingress Controller ──────────────────────────────────────────
echo ""
echo "▶ Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

echo ""
echo "▶ Waiting for Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo "✔ NGINX Ingress Controller ready"

# ── Install cert-manager ──────────────────────────────────────────────────────
echo ""
echo "▶ Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.5/cert-manager.yaml

echo ""
echo "▶ Waiting for cert-manager to be ready..."
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=cert-manager \
  --timeout=120s
echo "✔ cert-manager ready"

# ── Apply Let's Encrypt ClusterIssuer ─────────────────────────────────────────
echo ""
echo "▶ Applying Let's Encrypt ClusterIssuer..."
kubectl apply -f k8s/cluster-issuer.yaml
echo "✔ ClusterIssuer applied"

# ── Verify ────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Cluster nodes:"
kubectl get nodes

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " AKS Cluster is ready!"
echo ""
echo " Next steps:"
echo "   1. Build & push Docker images to Docker Hub:"
echo "         ./build-and-push.sh v1.0.0 https://gerald.az.ironlabs.online"
echo ""
echo "   2. Fill in secrets:"
echo "         cp secrets.env.example secrets.env"
echo "         # edit secrets.env with real values"
echo ""
echo "   3. Deploy the app to the cluster:"
echo "         ./k8s-deploy.sh"
echo ""
echo "   4. Point DNS at the Ingress IP:"
echo "         ./aks-dns.sh"
echo ""
echo "   5. App will be live at:"
echo "         https://gerald.az.ironlabs.online"
echo ""
echo " To tear down the app (keeps cluster):"
echo "   ./k8s-teardown.sh"
echo ""
echo " To delete the entire cluster:"
echo "   ./aks-teardown.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
