#!/usr/bin/env bash
# Installe Argo CD dans le cluster courant, puis déclare les trois applications.
# Prérequis : le dépôt est public sur GitHub et GITHUB_USER a été remplacé partout.
# Usage :  bash scripts/install-argocd.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if grep -rq "GITHUB_USER" "$ROOT/argocd" "$ROOT/deploy"; then
  echo "GITHUB_USER n'a pas été remplacé dans argocd/ et deploy/. Voir le README."
  exit 1
fi

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Apply côté serveur : certaines CRD d'Argo CD sont trop volumineuses pour un apply classique.
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

kubectl apply -f "$ROOT/argocd/"

echo
echo "Mot de passe initial de l'utilisateur admin :"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo
echo
echo "Interface Argo CD :  kubectl -n argocd port-forward svc/argocd-server 8081:443"
echo "puis https://localhost:8081 (utilisateur : admin)"
