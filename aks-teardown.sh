#!/bin/bash
# ─── Restauranty – Delete AKS Cluster ────────────────────────────────────────
# Deletes the AKS cluster and the entire resource group (all resources inside).
#
# Usage:
#   chmod +x aks-teardown.sh
#   ./aks-teardown.sh          # prompts for confirmation
#   ./aks-teardown.sh --force  # skips confirmation prompt
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

RESOURCE_GROUP="geraldAKSGroup"
CLUSTER_NAME="geraldAKSCluster"
FORCE="${1:-}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Restauranty – AKS Cluster Teardown"
echo " Resource Group: $RESOURCE_GROUP"
echo " Cluster       : $CLUSTER_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Confirmation prompt ───────────────────────────────────────────────────────
if [ "$FORCE" != "--force" ]; then
  echo ""
  echo "⚠️  WARNING: This will permanently delete:"
  echo "   - AKS cluster '$CLUSTER_NAME'"
  echo "   - Resource group '$RESOURCE_GROUP'"
  echo "   - ALL resources inside it (disks, load balancers, public IPs)"
  echo ""
  read -r -p "   Are you sure? Type 'yes' to continue: " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo ""
    echo "✖ Aborted."
    exit 0
  fi
fi

echo ""
echo "▶ Deleting resource group '$RESOURCE_GROUP' (this takes ~5 minutes)..."
az group delete \
  --name "$RESOURCE_GROUP" \
  --yes \
  --no-wait
echo "✔ Deletion triggered (running in background)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Teardown initiated."
echo ""
echo " Monitor deletion progress:"
echo "   az group show --name $RESOURCE_GROUP --query properties.provisioningState"
echo ""
echo " Confirm it's gone:"
echo "   az group list --output table"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
