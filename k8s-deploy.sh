#!/bin/bash
# ─── Restauranty – Deploy to Kubernetes ──────────────────────────────────────
# Prerequisites:
#   - kubectl configured and pointing at your cluster
#   - NGINX Ingress Controller installed:
#       kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
#   - secrets.env file present at the project root (never committed to Git)
#     Copy secrets.env.example → secrets.env and fill in real values
#
# Usage:
#   chmod +x k8s-deploy.sh
#   ./k8s-deploy.sh
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

SECRETS_FILE="secrets.env"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Restauranty – Kubernetes Deploy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Validate secrets.env exists ───────────────────────────────────────────────
if [ ! -f "$SECRETS_FILE" ]; then
  echo ""
  echo "✖ ERROR: '$SECRETS_FILE' not found."
  echo "  Copy secrets.env.example → secrets.env and fill in real values."
  echo "  This file must never be committed to Git."
  exit 1
fi

echo ""
echo "▶ Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# ── Create/update secret from secrets.env ─────────────────────────────────────
echo ""
echo "▶ Applying secrets from $SECRETS_FILE ..."
kubectl create secret generic restauranty-secrets \
  --from-env-file="$SECRETS_FILE" \
  --namespace=restauranty \
  --dry-run=client -o yaml | kubectl apply -f -
echo "✔ Secret applied (values never written to disk)"

echo ""
echo "▶ Deploying MongoDB..."
kubectl apply -f k8s/mongo.yaml
kubectl rollout status deployment/mongo -n restauranty

echo ""
echo "▶ Deploying microservices..."
kubectl apply -f k8s/auth.yaml
kubectl apply -f k8s/discounts.yaml
kubectl apply -f k8s/items.yaml

echo ""
echo "▶ Deploying frontend..."
kubectl apply -f k8s/frontend.yaml

echo ""
echo "▶ Applying Ingress..."
kubectl apply -f k8s/ingress.yaml

echo ""
echo "▶ Waiting for rollouts..."
kubectl rollout status deployment/auth       -n restauranty
kubectl rollout status deployment/discounts  -n restauranty
kubectl rollout status deployment/items      -n restauranty
kubectl rollout status deployment/frontend   -n restauranty

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " All resources deployed!"
echo ""
echo " Check pod status:"
echo "   kubectl get pods -n restauranty"
echo ""
echo " Get Ingress IP:"
echo "   kubectl get ingress -n restauranty"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
