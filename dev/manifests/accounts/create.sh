kubectl apply -f dev/manifests/accounts/nfs-service-accounts.yaml
kubectl apply -f dev/manifests/accounts/nfs-ns-role.yaml
kubectl apply -f dev/manifests/accounts/nfs-role-bindings.yaml
kubectl apply -f dev/manifests/accounts/nfs-secrets.yaml
kubectl apply -f dev/manifests/accounts/read-cm-role.yaml
