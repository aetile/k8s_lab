#!/usr/bin/env bash
# Crée le cluster kind "cka" (1 plan de contrôle + 2 workers).
# S'il existe déjà, le script s'arrête sans rien modifier.
#
# Usage :  bash scripts/create-cluster.sh
set -euo pipefail

CLUSTER_NAME="cka"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  echo ">> Le cluster '$CLUSTER_NAME' existe déjà : rien à faire."
  exit 0
fi

kind create cluster --name "$CLUSTER_NAME" --config "$ROOT/kind.yaml"

kubectl cluster-info --context "kind-${CLUSTER_NAME}"
kubectl get nodes
