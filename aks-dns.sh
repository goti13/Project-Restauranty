#!/bin/bash
# ─── Restauranty – Point Azure DNS at AKS Ingress ────────────────────────────
# Run this AFTER ./k8s-deploy.sh
# Creates/updates the A record for gerald.az.ironlabs.online → Ingress IP
#
# Prerequisites:
#   - Azure CLI logged in
#   - kubectl configured and pointing at geraldAKSCluster
#   - The Azure DNS zone 'ironlabs.online' must exist in your subscription
#
# Usage:
#   chmod +x aks-dns.sh
#   ./aks-dns.sh
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
RESOURCE_GROUP="goti-dns-rg"
DNS_ZONE="gerald.az.ironlabs.online"
DNS_RECORD="@"          # root of gerald.az.ironlabs.online
TTL=300

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Restauranty – Azure DNS Update"
echo " Zone   : $DNS_ZONE"
echo " Record : $DNS_RECORD.$DNS_ZONE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Get Ingress public IP ─────────────────────────────────────────────────────
echo ""
echo "▶ Waiting for Ingress public IP to be assigned..."

INGRESS_IP=""
RETRIES=20
for i in $(seq 1 $RETRIES); do
  INGRESS_IP=$(kubectl get ingress restauranty-ingress \
    --namespace restauranty \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)

  if [ -n "$INGRESS_IP" ]; then
    break
  fi

  echo "   Attempt $i/$RETRIES — IP not yet assigned, retrying in 15s..."
  sleep 15
done

if [ -z "$INGRESS_IP" ]; then
  echo ""
  echo "✖ ERROR: Could not retrieve Ingress public IP after $RETRIES attempts."
  echo "  Check: kubectl get ingress -n restauranty"
  exit 1
fi

echo "✔ Ingress public IP: $INGRESS_IP"

# ── Create or update DNS A record ─────────────────────────────────────────────
echo ""
echo "▶ Creating/updating A record '$DNS_RECORD' → $INGRESS_IP ..."
az network dns record-set a add-record \
  --resource-group "$RESOURCE_GROUP" \
  --zone-name "$DNS_ZONE" \
  --record-set-name "$DNS_RECORD" \
  --ipv4-address "$INGRESS_IP" \
  --ttl "$TTL"

echo "✔ DNS A record set: $DNS_RECORD.$DNS_ZONE → $INGRESS_IP"

# ── Verify ────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Current DNS record:"
az network dns record-set a show \
  --resource-group "$RESOURCE_GROUP" \
  --zone-name "$DNS_ZONE" \
  --name "$DNS_RECORD" \
  --output table

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " DNS update complete!"
echo ""
echo " Your app will be available at:"
echo "   https://gerald.az.ironlabs.online"
echo ""
echo " Note: DNS propagation takes 1-5 minutes."
echo " TLS cert issuance by Let's Encrypt takes 1-2 minutes after DNS resolves."
echo ""
echo " Check cert status:"
echo "   kubectl get certificate -n restauranty"
echo "   kubectl describe certificate restauranty-tls -n restauranty"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
