# AGENTS.md

This file provides context for AI agents and assistants working with this repository.

## What This Repo Is

Kubernetes manifests and Helm configurations for the **perseus** RKE2 cluster —
a single-node (expanding to 3-node HA) Kubernetes cluster running on RackNerd KVM VPS.

## Cluster Architecture

| Item | Value |
|---|---|
| Distribution | RKE2 |
| Master node | perseus |
| Public IP | 198.12.95.168 |
| Tailscale IP | 100.69.52.115 |
| Tailnet | polecat-grue.ts.net |
| OS | openSUSE Leap 15.6 |
| API endpoint | https://perseus:6443 |
| Overlay network | Tailscale (all inter-node traffic) |
| Storage | Longhorn |
| Ingress | ingress-nginx (hostNetwork) |
| TLS | cert-manager + Let's Encrypt |

## Repo Structure

```
.
├── cert-manager/          # ClusterIssuer for Let's Encrypt
├── ingress-nginx/         # RKE2 ingress-nginx hostNetwork config
├── podinfo/               # Demo app at podinfo.rk6.dev
├── pornogurmani/          # Placeholder site for pornogurmani.com
└── postgresql/            # CloudNativePG-managed PostgreSQL cluster
```

## Conventions

- All manifests are plain YAML — no Helm templating unless explicitly in a `charts/` subdirectory
- Each app lives in its own directory with a `README.md` explaining install/verify steps
- Ingress resources always use `ingressClassName: nginx`
- TLS is always handled via cert-manager annotation `cert-manager.io/cluster-issuer: letsencrypt-prod`
- Secrets are NEVER committed — use `*.secret.yaml` naming if generating locally (gitignored)
- Namespace is specified explicitly in every manifest

## Adding a New App

1. Create a new directory `<appname>/`
2. Add a `<appname>.yaml` with Deployment + Service + Ingress (and ConfigMap if needed)
3. Add a `README.md` with install, verify, and DNS instructions
4. Ensure the Ingress has the cert-manager annotation for automatic TLS
5. Add DNS A record pointing to `198.12.95.168`

## Deployment Order (fresh cluster)

1. `ingress-nginx/` — copy HelmChartConfig to `/var/lib/rancher/rke2/server/manifests/` on perseus
2. `cert-manager/` — install via Helm, then `kubectl apply -f cluster-issuer.yaml`
3. `podinfo/` — smoke test for ingress + TLS
4. `pornogurmani/` — placeholder site
5. `postgresql/` — install CNPG operator via Helm, apply namespace, SealedSecret, then Cluster CR

## Important Notes

- All cluster traffic between nodes flows over **Tailscale** — never expose cluster ports publicly
- `node-ip` and `advertise-address` in RKE2 config must always be the Tailscale IP
- CoreDNS is configured to forward to `8.8.8.8 8.8.4.4` before `/etc/resolv.conf` to ensure pods can resolve public hostnames
- Perseus's public IP (`198.12.95.168`) is used for all public DNS A records
- Ports 80 and 443 are open in firewalld public zone for ingress traffic only
- All other public ports are blocked — management is exclusively over Tailscale

## Future Plans

- Add deimos and phobos as additional server nodes for etcd HA (3-node cluster)
- Bump Longhorn replica count to 3 once all nodes are Ready
- Replace pornogurmani placeholder with a Rust + React app
