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
