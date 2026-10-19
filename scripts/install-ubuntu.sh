#!/usr/bin/env bash
# Installe Docker, kubectl et kind sur Ubuntu, puis prépare l'environnement
# pour s'entraîner à la CKA (alias, complétion).
#
# Usage :  bash install-ubuntu.sh
# Variable optionnelle :  KIND_VERSION=v0.XX.Y bash install-ubuntu.sh
set -euo pipefail

# --- Architecture ---------------------------------------------------------
case "$(uname -m)" in
  x86_64)  ARCH=amd64 ;;
  aarch64) ARCH=arm64 ;;
  *) echo "Architecture non prise en charge : $(uname -m)"; exit 1 ;;
esac

# --- Docker ---------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo ">> Installation de Docker"
  sudo apt-get update
  sudo apt-get install -y docker.io curl ca-certificates
  sudo systemctl enable --now docker
else
  echo ">> Docker déjà installé"
fi

if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"
  echo ">> Utilisateur ajouté au groupe docker : déconnectez-vous puis reconnectez-vous"
  echo "   (ou lancez 'newgrp docker') pour que cela prenne effet."
fi

# --- kubectl --------------------------------------------------------------
if ! command -v kubectl >/dev/null 2>&1; then
  echo ">> Installation de kubectl"
  KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
  sudo install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  rm -f /tmp/kubectl
else
  echo ">> kubectl déjà installé"
fi

# --- kind -----------------------------------------------------------------
if ! command -v kind >/dev/null 2>&1; then
  echo ">> Installation de kind"
  if [ -z "${KIND_VERSION:-}" ]; then
    KIND_VERSION="$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest \
      | grep '"tag_name"' | head -n1 | cut -d '"' -f4)"
  fi
  curl -fsSLo /tmp/kind "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-${ARCH}"
  sudo install -m 0755 /tmp/kind /usr/local/bin/kind
  rm -f /tmp/kind
else
  echo ">> kind déjà installé"
fi

# --- Confort pour la CKA (ajouté une seule fois) ---------------------------
MARK="# >>> cka-setup >>>"
if ! grep -qF "$MARK" "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<'EOF'
# >>> cka-setup >>>
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"
# <<< cka-setup <<<
EOF
  echo ">> Alias ajoutés à ~/.bashrc (k, \$do, \$now). Lancez 'source ~/.bashrc'."
fi

echo
echo "Versions installées :"
docker --version || true
kubectl version --client || true
kind version || true
echo
echo "Étape suivante :  kind create cluster --name cka --config kind.yaml"
