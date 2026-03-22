# perseus-k8s

Kubernetes manifests and Helm configurations for the perseus RKE2 cluster.

## Structure

```
.
├── cert-manager/          # ClusterIssuer for Let's Encrypt
├── ingress-nginx/         # RKE2 ingress-nginx hostNetwork config
├── podinfo/               # Demo app at podinfo.rk6.dev
└── pornogurmani/          # Placeholder site for pornogurmani.com
```

## Prerequisites

- RKE2 running on perseus with Tailscale overlay
- `kubectl` configured locally (`~/.kube/config` pointing to `perseus:6443`)
- Helm 3 installed locally
- `kubeseal` CLI for sealed secrets (PostgreSQL setup)

## Quick Start with Just

This repository uses [just](https://github.com/casey/just) for task automation.

### Install just

**Windows (PowerShell):**
```powershell
# Via scoop
scoop install just

# Or via chocolatey
choco install just

# Or via winget
winget install --id Casey.Just
```

**Linux:**
```bash
# Via package manager (Debian/Ubuntu)
sudo apt install just

# Or download from releases
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
```

### Check Dependencies

Before deploying anything, verify all required tools are installed:

```bash
just dep-check
```

This will check for:
- `kubectl` - Kubernetes CLI
- `helm` - Helm 3 package manager
- `kubeseal` - Sealed Secrets CLI
- `ssh` - OpenSSH client
- `tailscale` - Tailscale VPN client
- `sed` - Stream editor (for kubeconfig modification)
- `grep` - Pattern matching tool

### Check Tailscale Connectivity

Verify that perseus is visible in your tailscale network:

```bash
just check-tailscale
```

This checks if perseus appears in `tailscale status` output.

### Get Kubeconfig

Fetch the kubeconfig from perseus and configure it for remote access:

```bash
just get-kubeconfig
```

This will:
1. Run dependency checks (kubectl, helm, kubeseal, ssh, tailscale, sed, grep)
2. Verify perseus is visible in tailscale network
3. SSH to root@perseus and fetch `/etc/rancher/rke2/rke2.yaml`
4. Replace `server: https://127.0.0.1:6443` with `server: https://perseus:6443`
5. Save to `.kube/config` (project-specific, gitignored)

To use the kubeconfig:

**PowerShell:**
```powershell
$env:KUBECONFIG = "$(pwd)\.kube\config"
kubectl get nodes
```

**Bash:**
```bash
export KUBECONFIG=$(pwd)/.kube/config
kubectl get nodes
```

### Available Commands

Run `just` without arguments to see all available commands:

```bash
just
```

## Deployment Order

1. **ingress-nginx** — must be applied first, binds ports 80/443
2. **cert-manager** — install via Helm, then apply ClusterIssuer
3. **podinfo** — demo app, verify TLS works end-to-end
4. **pornogurmani** — placeholder site

## Cluster Info

| Item | Value |
|---|---|
| Master node | perseus (perseus.polecat-grue.ts.net) |
| Public IP | 198.12.95.168 |
| Tailscale IP | 100.69.52.115 |
| RKE2 API | https://perseus:6443 |
| Tailnet | polecat-grue.ts.net |
