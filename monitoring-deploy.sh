#!/bin/bash
# ─── Restauranty – Deploy Monitoring Stack via Helm ──────────────────────────
# Installs: kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
#           loki-stack (Loki + Promtail)
#
# Prerequisites:
#   - helm installed (https://helm.sh/docs/intro/install/)
#   - kubectl configured and pointing at geraldAKSCluster
#   - cert-manager installed (already done via aks-create.sh)
#   - App already deployed (k8s-deploy.sh already run)
#
# Usage:
#   chmod +x monitoring-deploy.sh
#   ./monitoring-deploy.sh
# ─────────────────────────────────────────────────────────────────────────────
 
set -euo pipefail
 
DNS_ZONE="gerald.az.ironlabs.online"
DNS_RG="goti-dns-rg"
GRAFANA_HOST="grafana.gerald.az.ironlabs.online"
INGRESS_IP="48.206.108.82"
 
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Restauranty – Monitoring Stack Deploy"
echo " Grafana : https://$GRAFANA_HOST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
 
# ── Add Helm repos ────────────────────────────────────────────────────────────
echo ""
echo "▶ Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
echo "✔ Helm repos ready"
 
# ── Create monitoring namespace ───────────────────────────────────────────────
echo ""
echo "▶ Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
echo "✔ Namespace ready"
 
# ── Install/Upgrade kube-prometheus-stack ────────────────────────────────────
echo ""
echo "▶ Installing/Upgrading kube-prometheus-stack (Prometheus + Grafana + Alertmanager)..."
echo "  This may take 3-5 minutes..."
helm upgrade --install prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values k8s/monitoring/prometheus-values.yaml \
  --timeout 10m \
  --wait
echo "✔ kube-prometheus-stack installed"
 
# ── Install/Upgrade Loki stack ────────────────────────────────────────────────
echo ""
echo "▶ Installing/Upgrading Loki + Promtail..."
helm upgrade --install loki \
  grafana/loki-stack \
  --namespace monitoring \
  --values k8s/monitoring/loki-values.yaml \
  --timeout 5m \
  --wait
echo "✔ Loki stack installed"
 
# ── Apply NetworkPolicy ───────────────────────────────────────────────────────
echo ""
echo "▶ Applying Grafana NetworkPolicy..."
kubectl apply -f k8s/monitoring/network-policy.yaml
echo "✔ NetworkPolicy applied"
 
# ── Create/update DNS A record ────────────────────────────────────────────────
echo ""
echo "▶ Creating DNS record grafana → $INGRESS_IP ..."
az network dns record-set a add-record \
  --resource-group "$DNS_RG" \
  --zone-name "$DNS_ZONE" \
  --record-set-name "grafana" \
  --ipv4-address "$INGRESS_IP" \
  --ttl 300 2>/dev/null || echo "  (record may already exist — skipping)"
echo "✔ DNS record set: $GRAFANA_HOST → $INGRESS_IP"
 
# ── Verify ────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Pod status:"
kubectl get pods -n monitoring
 
echo ""
echo "▶ Checking TLS certificate..."
kubectl get certificate -n monitoring 2>/dev/null || echo "  (cert may still be issuing)"
 
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Monitoring stack deployed!"
echo ""
echo " Grafana : https://$GRAFANA_HOST"
echo " User    : admin"
echo " Password: Restauranty@Grafana2026!"
echo ""
echo " Note: TLS cert may take 1-2 minutes to issue."
echo ""
echo " Port-forward Prometheus locally:"
echo "   kubectl port-forward svc/prometheus-stack-kube-prom-prometheus 9090:9090 -n monitoring"
echo ""
echo " Port-forward Loki locally:"
echo "   kubectl port-forward svc/loki 3100:3100 -n monitoring"
echo ""
echo " To upgrade monitoring stack:"
echo "   ./monitoring-deploy.sh"
echo ""
echo " To uninstall monitoring:"
echo "   helm uninstall prometheus-stack -n monitoring"
echo "   helm uninstall loki -n monitoring"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
