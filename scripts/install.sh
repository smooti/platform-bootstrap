#!/bin/bash
set -euo pipefail

# Default values
ARGOCD_NAMESPACE="argocd"
ARGOCD_CHART_VERSION="9.1.5"
EXTERNAL_SECRETS_CHART_VERSION="1.1.1"

REPO_ROOT=$(git rev-parse --show-toplevel)
source "${REPO_ROOT}/scripts/utilities.sh"

# Install ArgoCD using Helm
function install_argocd() {
    echo -e "🔄 ${BOLD}${GREEN}Installing ArgoCD...${NC}"

    # Add, update, and install the ArgoCD Helm repository
    helm repo add argo https://argoproj.github.io/argo-helm > /dev/null
    helm repo update > /dev/null
    helm upgrade --install argocd argo/argo-cd \
      --namespace "${ARGOCD_NAMESPACE}" --create-namespace \
      --version "${ARGOCD_CHART_VERSION}" > /dev/null
    
		echo -e "${YELLOW}⏳ Waiting for Argo CD to be healthy...${NC}"
		kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s > /dev/null

    echo -e "✅ ${BOLD}${BLUE}ArgoCD successfully installed.${NC}"
}

# Install External Secrets Operator using Helm
function install_external_secrets() {
	echo -e "${BOLD}${GREEN}🔄 Installing External Secrets...${NC}"
	helm repo add external-secrets "https://charts.external-secrets.io" > /dev/null
	helm repo update > /dev/null
	helm upgrade --install --wait external-secrets external-secrets/external-secrets \
		--namespace external-secrets --create-namespace \
		--version $EXTERNAL_SECRETS_CHART_VERSION > /dev/null

	echo -e "${YELLOW}⏳ Waiting for External Secrets to be healthy...${NC}"
	kubectl wait --for=condition=available deployment/external-secrets -n external-secrets --timeout=300s > /dev/null

	echo -e "✅ ${BOLD}${BLUE}External-Secrets Operator successfully installed.${NC}"
}

function install_app_of_apps() {
		echo -e "🔄 ${BOLD}${GREEN}Installing ArgoCD Application of Applications...${NC}"

		kubectl apply -f "${REPO_ROOT}/apps/argo-root/root-application.yaml" > /dev/null

		echo -e "✅ ${BOLD}${BLUE}ArgoCD Application of Applications successfully installed.${NC}"
}

# Final Instructions
function final_instructions() { 
    # Get the initial password for the 'admin' user
    initial_password=$(kubectl get secret argocd-initial-admin-secret -n "${ARGOCD_NAMESPACE}" -o jsonpath="{.data.password}" | base64 -d)
    echo "--------------------------------------------------------"
    echo "ArgoCD Credentials:"
    echo "  Username: admin"
    echo "  Initial Password: ${initial_password}"
    echo ""
		echo "Set up port forwarding with:"
		echo "  kubectl port-forward -n ${ARGOCD_NAMESPACE} svc/argocd-server 8080:443"
    echo ""
    echo "NEXT STEP: Manually log into ArgoCD and configure any applications you want to manage."
    echo "--------------------------------------------------------"
}

# --- Main Execution ---
echo -e "\n${BOLD}${BLUE}🚀 Starting installation process...${NC}"
install_argocd
# install_external_secrets
install_app_of_apps
final_instructions