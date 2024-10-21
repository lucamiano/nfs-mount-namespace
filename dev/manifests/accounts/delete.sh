kubectl delete -f dev/manifests/accounts/nfs-secrets.yaml
kubectl delete -f dev/manifests/accounts/nfs-role-bindings.yaml
kubectl delete -f dev/manifests/accounts/nfs-ns-role.yaml
kubectl delete -f dev/manifests/accounts/nfs-service-accounts.yaml
kubectl delete -f dev/manifests/accounts/read-cm-role.yaml



