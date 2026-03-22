# podinfo

A small Go demo app useful for testing ingress and TLS.

## Install

```bash
helm repo add podinfo https://stefanprodan.github.io/podinfo
helm repo update
helm install podinfo podinfo/podinfo \
  --namespace podinfo \
  --create-namespace
```

## Apply Ingress

```bash
kubectl apply -f ingress.yaml
```

## Verify

```bash
kubectl get certificate -n podinfo -w
# Wait for READY: True, then:
curl https://podinfo.rk6.dev
```
