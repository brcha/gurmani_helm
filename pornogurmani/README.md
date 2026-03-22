# pornogurmani

Placeholder site for pornogurmani.com — a culinary collective. To be replaced
with a proper Rust + React app when ready.

## Deploy

```bash
kubectl apply -f pornogurmani.yaml
```

## Verify

```bash
kubectl get pods | grep pornogurmani
kubectl get certificate -n default -w
# Wait for READY: True
```

## DNS

Ensure the following DNS records point to perseus's public IP:

| Record | Type | Value |
|---|---|---|
| pornogurmani.com | A | 198.12.95.168 |
| www.pornogurmani.com | CNAME | pornogurmani.com |

## Replacing with real app

When the real app is ready:

```bash
kubectl delete deployment pornogurmani
kubectl delete configmap pornogurmani-html
# Deploy real app, keeping the Ingress and TLS secret intact
```
