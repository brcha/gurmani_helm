# postgresql

CloudNativePG-managed PostgreSQL cluster on the perseus RKE2 cluster.

## Components

| File | Description |
|---|---|
| `cnpg-operator.yaml` | Documents the Helm install command for the CNPG operator |
| `namespace.yaml` | `postgres` namespace |
| `pg-superuser-secret.sealedsecret.yaml` | Instructions for generating the SealedSecret (placeholder) |
| `pg-cluster.yaml` | CloudNativePG `Cluster` CR — single instance now, HA-ready for 3 nodes |

## Prerequisites

- Sealed Secrets controller installed in the cluster (`kube-system` namespace)
- `kubeseal` CLI installed locally
- CNPG operator installed (see below)

## Install

### 1. Install the CNPG operator (once per cluster)

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace
```

Verify:
```bash
kubectl get deployment -n cnpg-system cnpg-cloudnative-pg
```

### 2. Apply the namespace

```bash
kubectl apply -f postgresql/namespace.yaml
```

### 3. Generate and apply the SealedSecret

```bash
kubectl create secret generic pg-superuser-secret \
  --namespace postgres \
  --from-literal=username=appuser \
  --from-literal=password='YourStrongPassword' \
  --dry-run=client -o yaml \
| kubeseal --controller-namespace kube-system --format yaml \
> postgresql/pg-superuser-secret.sealedsecret.yaml

kubectl apply -f postgresql/pg-superuser-secret.sealedsecret.yaml
```

### 4. Apply the cluster

```bash
kubectl apply -f postgresql/pg-cluster.yaml
```

### 5. Verify

```bash
kubectl get cluster -n postgres
kubectl get pods -n postgres
```

Expected output once healthy:
```
NAME         AGE   INSTANCES   READY   STATUS                     PRIMARY
pg-cluster   ...   1           1       Cluster in healthy state   pg-cluster-1
```

## Upgrade to HA (after deimos and phobos join)

Edit `pg-cluster.yaml` and set `instances: 3`, then:

```bash
kubectl apply -f postgresql/pg-cluster.yaml
```

CNPG will automatically provision and distribute two additional replicas across the new nodes.
Also bump Longhorn default replica count to 3 in the Longhorn UI.

## Connecting

Applications inside the cluster connect via the CNPG-managed services:

| Service | Purpose |
|---|---|
| `pg-cluster-rw.postgres.svc` | Read-write (primary) |
| `pg-cluster-ro.postgres.svc` | Read-only (replicas, available after HA) |
| `pg-cluster-r.postgres.svc` | Any instance |

Port: `5432`

## Useful commands

```bash
# Cluster status
kubectl cnpg status pg-cluster -n postgres

# Drop into psql on the primary
kubectl cnpg psql pg-cluster -n postgres

# Watch logs
kubectl logs -n postgres -l cnpg.io/cluster=pg-cluster -f
```
