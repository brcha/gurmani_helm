# ingress-nginx

RKE2 ships with ingress-nginx built-in. This config enables hostNetwork and hostPort
so that ports 80 and 443 are bound on the node.

## Apply

Copy to the RKE2 manifests directory — RKE2 watches this and applies automatically:

```bash
cp rke2-ingress-nginx-config.yaml /var/lib/rancher/rke2/server/manifests/
```

No restart needed. Wait ~30 seconds then verify:

```bash
ss -tlnp | grep -E '80|443'
# Should show 0.0.0.0:80 and 0.0.0.0:443
```

## Expose publicly

Open ports in firewalld when ready to serve public traffic:

```bash
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
```
