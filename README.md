# Platform Bootstrap

A GitOps-powered platform bootstrap solution that sets up ArgoCD and core platform components using the Application of Applications pattern.

## Overview

This repository provides a complete bootstrap solution for deploying a Kubernetes platform using ArgoCD and GitOps principles. It automatically installs ArgoCD, configures it with an Application of Applications pattern, and deploys essential platform components like cert-manager and Kyverno.

## Architecture

The bootstrap follows a hierarchical GitOps structure:

```
Platform Bootstrap (this repo)
├── ArgoCD (installed via Helm)
├── Root Application (manages itself and child apps)
├── Platform Project (defines deployment boundaries)
└── Core Applications (cert-manager, kyverno, etc.)
```

## Quick Start

### Prerequisites

Ensure you have the following tools installed:

- [**kubectl**](https://kubernetes.io/docs/tasks/tools/) - Kubernetes CLI
- [**helm**](https://helm.sh/docs/intro/install/) - Kubernetes package manager
- A running Kubernetes cluster with admin access

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/smooti/platform-bootstrap.git
   cd platform-bootstrap
   ```

2. **Run the bootstrap script:**
   ```bash
   ./scripts/install.sh
   ```


## What Gets Installed

### ArgoCD
- **Version:** 9.1.5
- **Namespace:** `argocd`
- **Features:** Full ArgoCD installation with UI, API server, and repo server

### Core Platform Components
- **cert-manager:** Certificate management for Kubernetes
- **Kyverno:** Kubernetes native policy management

### ArgoCD Configuration
- **Root Application:** Manages the entire platform bootstrap
- **Platform Project:** Defines deployment boundaries and permissions
- **Application of Applications:** Hierarchical app management

## Directory Structure

```
platform-bootstrap/
├── apps/                    # ArgoCD applications
│   ├── argo-root/          # Root application configuration
│   └── core/               # Core platform components
├── helm-values/            # Helm value overrides
├── projects/               # ArgoCD project definitions
└── scripts/                # Installation and utility scripts
    ├── install.sh         # Main bootstrap script
    └── utilities.sh       # Shared functions and colors
```

## Key Components

### Root Application (`apps/argo-root/root-application.yaml`)
The root application that manages the entire platform bootstrap process. It uses multiple sources to sync:
- Platform projects
- Core applications
- Itself (for self-healing)

### Platform Project (`projects/platform.yaml`)
Defines the boundaries and permissions for platform-level deployments, allowing deployment to any namespace and cluster.

### Core Applications
- **cert-manager:** Automated certificate management
- **Kyverno:** Policy engine for Kubernetes resources

## Development

### Adding New Components

1. **Create application manifests** in `apps/core/` or create new directories
2. **Add Helm values** in `helm-values/` if needed
3. **Update the root application** to include new sources if required

### Modifying Existing Components

1. Edit the YAML manifests in the appropriate `apps/` subdirectory
2. Update Helm values in `helm-values/` as needed
3. Commit and push changes - ArgoCD will automatically sync

## Security Considerations

- The default ArgoCD admin password should be changed after initial setup
- Review and customize the platform project permissions for your environment
- Consider enabling ArgoCD SSO integration for production use

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly in a development environment
5. Submit a pull request
