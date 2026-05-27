#!/bin/bash
# ─── Restauranty – Teardown Kubernetes Deployment ────────────────────────────
# Deletes the entire 'restauranty' namespace and all resources inside it.
#
# Usage:
#   chmod +x k8s-teardown.sh
#   ./k8s-teardown.sh          # prompts for confirmation
#   ./k8s-teardown.sh --force  # skips confirmation prompt
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

NAMESPACE="restauranty"
FORCE="${1:-}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Restauranty – Kubernetes Teardown"
echo " Namespace: $NAMESPACE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Confirmation prompt ───────────────────────────────────────────────────────
if [ "$FORCE" != "--force" ]; then
  echo ""
  echo "⚠️  WARNING: This will permanently delete the '$NAMESPACE' namespace"
  echo "   and everything inside it (pods, services, secrets, ingress)."
  echo ""
  echo "⚠️  NOTE: On cloud providers (EKS, AKS, GKE), the underlying storage"
  echo "   volume (EBS, Azure Disk, etc.) may NOT be deleted automatically."
  echo "   Check your cloud console for orphaned volumes after teardown."
  echo ""
  read -r -p "   Are you sure? Type 'yes' to continue: " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo ""
    echo "✖ Aborted."
    exit 0
  fi
fi

echo ""
echo "▶ Deleting namespace '$NAMESPACE'..."
kubectl delete namespace "$NAMESPACE" --ignore-not-found

echo ""
echo "▶ Waiting for namespace to be fully terminated..."
kubectl wait --for=delete namespace/"$NAMESPACE" --timeout=90s 2>/dev/null || true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Teardown complete."
echo ""
echo " If on a cloud provider, verify no orphaned volumes remain:"
echo "   AWS : aws ec2 describe-volumes --filters Name=status,Values=available"
echo "   AKS : az disk list --query \"[?diskState=='Unattached']\""
echo "   GKE : gcloud compute disks list --filter='NOT users:*'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
