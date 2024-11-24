## Create namespace for the webhook
kubectl create namespace nfs

## Create certificate for the webhook
kubectl apply -f dev/manifests/cert-manager/nfs-pod-access-control-certificate.yaml

## Install helm package
helm install nfs-pod-access-control helm -n nfs --create-namespace

## Map NFS users in configmap
scripts/add-user.sh user1 1001
scripts/add-user.sh user2 1002
scripts/add-user.sh user3 1003



