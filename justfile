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
        try {
            $kubectlOutput = kubectl version --client 2>$null | Select-String "Client Version"
            if ($kubectlOutput -and ($kubectlOutput -match 'v\d+\.\d+\.\d+')) {
                $version = $Matches[0]
                Write-Host "✓ kubectl found ($version)" -ForegroundColor Green
            } else {
                Write-Host "✗ kubectl found but version extraction failed - please verify installation" -ForegroundColor Red
                $missing = 1
            }
        } catch {
            Write-Host "✗ kubectl found but version extraction failed - please verify installation" -ForegroundColor Red
            $missing = 1
        }
    } else {
        Write-Host "✗ kubectl missing - install from https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Red
        $missing = 1
    }
    
    # Check helm
    if (Get-Command helm -ErrorAction SilentlyContinue) {
        try {
            $helmOutput = helm version --short 2>$null
            if ($helmOutput -match 'v\d+\.\d+\.\d+') {
                $version = $Matches[0]
                Write-Host "✓ helm found ($version)" -ForegroundColor Green
            } else {
                Write-Host "✗ helm found but version extraction failed - please verify installation" -ForegroundColor Red
                $missing = 1
            }
        } catch {
            Write-Host "✗ helm found but version extraction failed - please verify installation" -ForegroundColor Red
            $missing = 1
        }
    } else {
        Write-Host "✗ helm missing - install from https://helm.sh/docs/intro/install/" -ForegroundColor Red
        $missing = 1
    }
    
    # Check kubeseal
    if (Get-Command kubeseal -ErrorAction SilentlyContinue) {
        try {
            $kubesealOutput = kubeseal --version 2>&1
            if ($kubesealOutput -match '(\d+\.\d+\.\d+)') {
                $version = "v" + $Matches[1]
                Write-Host "✓ kubeseal found ($version)" -ForegroundColor Green
            } else {
                Write-Host "✗ kubeseal found but version extraction failed - please verify installation" -ForegroundColor Red
                $missing = 1
            }
        } catch {
            Write-Host "✗ kubeseal found but version extraction failed - please verify installation" -ForegroundColor Red
            $missing = 1
        }
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
        Write-Host "Some dependencies are missing or have issues. Please fix them and try again." -ForegroundColor Yellow
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
        kubectlOutput=$(kubectl version --client 2>/dev/null | grep "Client Version")
        if [[ $kubectlOutput =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            version="${BASH_REMATCH[0]}"
            echo "✓ kubectl found ($version)"
        else
            echo "✗ kubectl found but version extraction failed - please verify installation"
            missing=1
        fi
    else
        echo "✗ kubectl missing - install from https://kubernetes.io/docs/tasks/tools/"
        missing=1
    fi
    
    # Check helm
    if command -v helm &> /dev/null; then
        helmOutput=$(helm version --short 2>/dev/null)
        if [[ $helmOutput =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            version="${BASH_REMATCH[0]}"
            echo "✓ helm found ($version)"
        else
            echo "✗ helm found but version extraction failed - please verify installation"
            missing=1
        fi
    else
        echo "✗ helm missing - install from https://helm.sh/docs/intro/install/"
        missing=1
    fi
    
    # Check kubeseal
    if command -v kubeseal &> /dev/null; then
        kubesealOutput=$(kubeseal --version 2>&1)
        if [[ $kubesealOutput =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
            version="v${BASH_REMATCH[1]}"
            echo "✓ kubeseal found ($version)"
        else
            echo "✗ kubeseal found but version extraction failed - please verify installation"
            missing=1
        fi
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
        echo "Some dependencies are missing or have issues. Please fix them and try again."
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
