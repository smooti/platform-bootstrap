<<COMMENT_BLOCK
# Default: no port forwarding
./install.sh

# Enable port forwarding on default port 8080
./install.sh --port-forward

# Enable port forwarding on custom port 9000
./install.sh --port-forward --port 9000

# Set environment and enable port forwarding
./install.sh --env staging --port-forward --port 8080

# View help
./install.sh --help
COMMENT_BLOCK

#!/bin/bash
set -euo pipefail

# Default values
CLUSTER_ENV="prod"
PORT_FORWARD="false"
PORT="8080"
ARGOCD_NAMESPACE="argocd"
ARGOCD_VERSION="9.1.5"
HELM_RELEASE_NAME="argocd"

# Parse named flags
while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            CLUSTER_ENV="$2"
            shift 2
            ;;
        --port-forward)
            PORT_FORWARD="true"
            shift
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --env ENV              Set cluster environment (dev, staging, prod). Default: prod"
            echo "  --port-forward         Enable port forwarding to ArgoCD service"
            echo "  --port PORT            Local port for port forwarding. Default: 8080"
            echo "  --help                 Display this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Install ArgoCD Core Components using Helm
function install_argocd() {
    echo "⚙️ Installing ArgoCD core components..."
    
    # Create the namespace for ArgoCD
    echo "Creating ArgoCD namespace: ${ARGOCD_NAMESPACE}..."
    kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

    # Add and update the ArgoCD Helm repository
    echo "Adding ArgoCD Helm repository..."
    helm repo add argo https://argoproj.github.io/argo-helm > /dev/null
    helm repo update > /dev/null

    # Install ArgoCD using the Helm chart
    echo "Installing ArgoCD Helm chart version ${ARGOCD_VERSION}..."
    helm install "${HELM_RELEASE_NAME}" argo/argo-cd \
      --namespace "${ARGOCD_NAMESPACE}" \
      --version "${ARGOCD_VERSION}" \
      --wait > /dev/null
      
    echo "✅ ArgoCD successfully installed. The core control plane is ready."
}

# Port Forward to ArgoCD Service
function setup_port_forward() {
    if [[ "${PORT_FORWARD}" == "true" ]]; then
        echo "🔌 Setting up port forward to ArgoCD service on localhost:${PORT}..."
        kubectl port-forward -n "${ARGOCD_NAMESPACE}" svc/argocd-server "${PORT}:443" &
        echo "✅ Port forward established. ArgoCD is accessible at https://localhost:${PORT}"
    fi
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
    if [[ "${PORT_FORWARD}" == "true" ]]; then
        echo "🔗 ArgoCD is accessible at: https://localhost:${PORT}"
    else
        echo "Set up port forwarding with:"
        echo "  kubectl port-forward -n ${ARGOCD_NAMESPACE} svc/argocd-server 8080:443"
    fi
    echo ""
    echo "NEXT STEP: Manually log into ArgoCD and configure any applications you want to manage."
    echo "--------------------------------------------------------"
}

# --- Main Execution ---
install_argocd
setup_port_forward
final_instructions