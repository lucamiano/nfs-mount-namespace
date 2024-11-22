## Install helm package
helm install nfs-pod-access-control nfs-pod-access-control -n nfs-pod-ac --create-namespace

## Create certificate for the webhook
kubectl apply -f dev/manifests/cert-manager/nfs-pod-access-control-certificate.yaml

## Map NFS users in configmap
scripts/add-user.sh user1 1001
scripts/add-user.sh user2 1002
scripts/add-user.sh user3 1003



