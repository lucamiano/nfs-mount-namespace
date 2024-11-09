# nfs-mount-namespace

## Installation
This project is meant to run on a real Kubernetes cluster 

### Requirements
* Pre-installed kubernetes cluster
* kubectl
* Go >=1.23 (optional)
* Helm


### Deploy Webhook
First of all to make out webhooks work we need a valid ssl certificate to use.
In order to do that we are going to use the helm package cert-manager.

#### Install Helm
Install Helm:
curl -fsSl -o get_helm.sh https://github.com/helm/helm/blob/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

Add Helm repo:
helm repo add jetstack https://charts.jetstack.io --force-update

Install cert-manager:
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.16.1 \
  --set crds.enabled=true

#### Deploy certificate authority and certificate

From project root directory run:
make deploy-ca
make deploy-certificate

To configure the cluster to use the admission and validation webhooks and to deploy said webhooks, simply run:
```

```

You can stream logs from it:
```
❯ make logs

🔍 Streaming nfs-mount-namespace logs...
kubectl logs -l app=nfs-mount-namespace -f
time="2021-09-03T04:59:10Z" level=info msg="Listening on port 443..."
time="2021-09-03T05:02:21Z" level=debug msg=healthy uri=/health
```

And hit it's health endpoint from your local machine:
```
❯ curl -k https://localhost:8443/health
OK
```

## Admission Logic
A set of validations and mutations are implemented in an extensible framework. Those happen on the fly when a pod is deployed and no further resources are tracked and updated (ie. no controller logic).

### Validating Webhooks
#### Implemented
- [uid validation](pkg/validation/uid_validator.go): validates that a pod contains the correct runAsUser option, UID has to map with the correct ServiceAccount that launched the command

### Mutating Webhooks
#### Implemented
- [mount home directory](pkg/mutation/mount_home_directory.go): inject runAsUser option inside pod, mapping UID with correct ServiceAccount in NFS home directory

To add a new pod mutation, create a file `pkg/mutation/MUTATION_NAME.go`, then create a new struct implementing the `mutation.podMutator` interface.

## Acknowledgements

- [slackhq/simple-kubernetes-webhook](https://github.com/slackhq/simple-kubernetes-webhook)
