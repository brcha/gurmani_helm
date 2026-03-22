# cert-manager

## Install

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set disableAutoApproval=false
```

## Apply ClusterIssuer

Edit `cluster-issuer.yaml` and replace `your@email.com` with your actual email, then:

```bash
kubectl apply -f cluster-issuer.yaml
```

## Verify

```bash
kubectl get clusterissuer letsencrypt-prod
# Should show READY: True
```
