# perseus-k8s justfile
# Task automation for Kubernetes manifest deployment

# Show available commands
default:
    @just --list

# Check if all required dependencies are installed (cross-platform)
dep-check:
    @just _dep-check-{{os()}}

# Dependency check for Windows (PowerShell)
_dep-check-windows:
    #!powershell.exe
    $ErrorActionPreference = "Stop"
    $missing = 0
    
    Write-Host "Checking dependencies..."
    
    # Check kubectl
    if (Get-Command kubectl -ErrorAction SilentlyContinue) {
        $version = (kubectl version --client --short 2>$null) -replace 'Client Version: ', ''
        if (-not $version) { $version = "installed" }
        Write-Host "✓ kubectl found ($version)" -ForegroundColor Green
    } else {
        Write-Host "✗ kubectl missing - install from https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Red
        $missing = 1
    }
    
    # Check helm
    if (Get-Command helm -ErrorAction SilentlyContinue) {
        $version = (helm version --short 2>$null) -replace 'v', ''
        if (-not $version) { $version = "installed" }
        Write-Host "✓ helm found ($version)" -ForegroundColor Green
    } else {
        Write-Host "✗ helm missing - install from https://helm.sh/docs/intro/install/" -ForegroundColor Red
        $missing = 1
    }
    
    # Check kubeseal
    if (Get-Command kubeseal -ErrorAction SilentlyContinue) {
        $version = (kubeseal --version 2>&1 | Select-Object -First 1)
        if (-not $version) { $version = "installed" }
        Write-Host "✓ kubeseal found ($version)" -ForegroundColor Green
    } else {
        Write-Host "✗ kubeseal missing - install from https://github.com/bitnami-labs/sealed-secrets/releases" -ForegroundColor Red
        $missing = 1
    }
    
    # Summary
    Write-Host ""
    if ($missing -eq 0) {
        Write-Host "All dependencies satisfied ✓" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Some dependencies are missing. Please install them and try again." -ForegroundColor Yellow
        exit 1
    }

# Dependency check for Linux/macOS (bash)
_dep-check-linux:
    #!/usr/bin/env bash
    set -euo pipefail
    
    missing=0
    
    echo "Checking dependencies..."
    
    # Check kubectl
    if command -v kubectl &> /dev/null; then
        version=$(kubectl version --client --short 2>/dev/null | sed 's/Client Version: //' || echo "installed")
        echo "✓ kubectl found ($version)"
    else
        echo "✗ kubectl missing - install from https://kubernetes.io/docs/tasks/tools/"
        missing=1
    fi
    
    # Check helm
    if command -v helm &> /dev/null; then
        version=$(helm version --short 2>/dev/null | sed 's/v//' || echo "installed")
        echo "✓ helm found ($version)"
    else
        echo "✗ helm missing - install from https://helm.sh/docs/intro/install/"
        missing=1
    fi
    
    # Check kubeseal
    if command -v kubeseal &> /dev/null; then
        version=$(kubeseal --version 2>&1 | head -n1 || echo "installed")
        echo "✓ kubeseal found ($version)"
    else
        echo "✗ kubeseal missing - install from https://github.com/bitnami-labs/sealed-secrets/releases"
        missing=1
    fi
    
    # Summary
    echo ""
    if [ $missing -eq 0 ]; then
        echo "All dependencies satisfied ✓"
        exit 0
    else
        echo "Some dependencies are missing. Please install them and try again."
        exit 1
    fi

# macOS uses the same check as Linux
_dep-check-macos:
    @just _dep-check-linux

# === Future Recipes (to be implemented) ===
# deploy-cert-manager:
#     # Deploy cert-manager via Helm
# 
# deploy-ingress-nginx:
#     # Copy config to perseus and restart RKE2
# 
# deploy-podinfo:
#     # Deploy podinfo demo app
# 
# deploy-all:
#     # Deploy everything in correct order
