#!/bin/bash
set -euo pipefail

CLUSTER_ENV="${1:-prod}"  # dev, staging, prod
ARGOCD_NAMESPACE="argocd"
ARGOCD_VERSION="9.1.5"
HELM_RELEASE_NAME="argocd"

# Install ArgoCD Core Components using Helm
function install_argocd() {
    echo "⚙️ Installing ArgoCD core components..."
    
    # Create the namespace for ArgoCD
    echo "Creating ArgoCD namespace: ${ARGOCD_NAMESPACE}..."
    kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

    # Add and update the ArgoCD Helm repository
    echo "Adding ArgoCD Helm repository..."
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update

    # Install ArgoCD using the Helm chart
    echo "Installing ArgoCD Helm chart version ${ARGOCD_VERSION}..."
    helm install "${HELM_RELEASE_NAME}" argo/argo-cd \
      --namespace "${ARGOCD_NAMESPACE}" \
      --version "${ARGOCD_VERSION}" \
      --wait # Wait for ArgoCD resources to be ready
      
    echo "✅ ArgoCD successfully installed. The core control plane is ready."
}

# Final Instructions
function final_instructions() {
    echo "🎉 ArgoCD Core Bootstrap Complete!"
    echo "--------------------------------------------------------"
    
    # Get the initial password for the 'admin' user
    initial_password=$(kubectl get secret argocd-initial-admin-secret -n "${ARGOCD_NAMESPACE}" -o jsonpath="{.data.password}" | base64 -d)
    
    echo "ArgoCD Credentials:"
    echo "  Username: admin"
    echo "  Initial Password: ${initial_password}"
    echo ""
    echo "NEXT STEP: Manually log into ArgoCD and configure any applications you want to manage."
    echo "--------------------------------------------------------"
}

# --- Main Execution ---
install_argocd
final_instructions