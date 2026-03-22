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
    $missing = 0
    Write-Host "Checking dependencies..."
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) { Write-Host "✗ kubectl missing" -ForegroundColor Red; $missing = 1 } else { Write-Host "✓ kubectl found" -ForegroundColor Green }
    if (-not (Get-Command helm -ErrorAction SilentlyContinue)) { Write-Host "✗ helm missing" -ForegroundColor Red; $missing = 1 } else { Write-Host "✓ helm found" -ForegroundColor Green }
    if (-not (Get-Command kubeseal -ErrorAction SilentlyContinue)) { Write-Host "✗ kubeseal missing" -ForegroundColor Red; $missing = 1 } else { Write-Host "✓ kubeseal found" -ForegroundColor Green }
    if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) { Write-Host "✗ ssh missing" -ForegroundColor Red; $missing = 1 } else { Write-Host "✓ ssh found" -ForegroundColor Green }
    if (-not (Get-Command tailscale -ErrorAction SilentlyContinue)) { Write-Host "✗ tailscale missing" -ForegroundColor Red; $missing = 1 } else { Write-Host "✓ tailscale found" -ForegroundColor Green }
    if (-not (Get-Command sed -ErrorAction SilentlyContinue)) { Write-Host "✗ sed missing" -ForegroundColor Red; $missing = 1 } else { Write-Host "✓ sed found" -ForegroundColor Green }
    if (-not (Get-Command grep -ErrorAction SilentlyContinue)) { Write-Host "✗ grep missing" -ForegroundColor Red; $missing = 1 } else { Write-Host "✓ grep found" -ForegroundColor Green }
    if ($missing -eq 0) { Write-Host "`nAll dependencies satisfied ✓" -ForegroundColor Green; exit 0 } else { Write-Host "`nSome dependencies missing" -ForegroundColor Yellow; exit 1 }

# Dependency check for Linux/macOS (bash)
_dep-check-linux:
    #!/usr/bin/env bash
    missing=0
    echo "Checking dependencies..."
    command -v kubectl &> /dev/null && echo "✓ kubectl found" || { echo "✗ kubectl missing"; missing=1; }
    command -v helm &> /dev/null && echo "✓ helm found" || { echo "✗ helm missing"; missing=1; }
    command -v kubeseal &> /dev/null && echo "✓ kubeseal found" || { echo "✗ kubeseal missing"; missing=1; }
    command -v ssh &> /dev/null && echo "✓ ssh found" || { echo "✗ ssh missing"; missing=1; }
    command -v tailscale &> /dev/null && echo "✓ tailscale found" || { echo "✗ tailscale missing"; missing=1; }
    command -v sed &> /dev/null && echo "✓ sed found" || { echo "✗ sed missing"; missing=1; }
    command -v grep &> /dev/null && echo "✓ grep found" || { echo "✗ grep missing"; missing=1; }
    [ $missing -eq 0 ] && { echo ""; echo "All dependencies satisfied ✓"; exit 0; } || { echo ""; echo "Some dependencies missing"; exit 1; }

# macOS uses the same check as Linux
_dep-check-macos:
    @just _dep-check-linux

# Verify tailscale connectivity to perseus
check-tailscale:
    tailscale status | grep perseus

# Fetch kubeconfig from perseus and configure for remote access
get-kubeconfig: dep-check check-tailscale
    mkdir -p .kube
    scp root@perseus:/etc/rancher/rke2/rke2.yaml .kube/config
    sed -i 's|https://127\.0\.0\.1:6443|https://perseus:6443|g' .kube/config

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
