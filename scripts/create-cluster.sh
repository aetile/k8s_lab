#!/usr/bin/env bash
# Crée le cluster kind (1 plan de contrôle + 2 workers) s'il n'existe pas déjà.
# Usage :  bash scripts/create-cluster.sh
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-lab}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo ">> Le cluster '$CLUSTER_NAME' existe déjà"
else
  kind create cluster --name "$CLUSTER_NAME" --config "$ROOT/kind.yaml"
fi

kubectl cluster-info --context "kind-${CLUSTER_NAME}"
kubectl get nodes
