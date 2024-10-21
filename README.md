# envd-server-pod-webhook

## Installation
This project is meant to run on a local Kubernetes cluster 

### Requirements
* Pre-installed kubernetes cluster
* kubectl
* Go >=1.23 (optional)


### Deploy Admission Webhook
To configure the cluster to use the admission webhook and to deploy said webhook, simply run:
```
```

You can stream logs from it:
```
❯ make logs

🔍 Streaming envd-server-pod-webhook logs...
kubectl logs -l app=envd-server-pod-webhook -f
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

#### How to add a new pod validation
To add a new pod mutation, create a file `pkg/validation/MUTATION_NAME.go`, then create a new struct implementing the `validation.podValidator` interface.

### Mutating Webhooks
#### Implemented
- [mount home directory](pkg/mutation/mount_home_directory.go): inject runAsUser option inside pod, mapping UID with correct ServiceAccount in NFS home directory

#### How to add a new pod mutation
To add a new pod mutation, create a file `pkg/mutation/MUTATION_NAME.go`, then create a new struct implementing the `mutation.podMutator` interface.

## Acknowledgements

- [slackhq/simple-kubernetes-webhook](https://github.com/slackhq/simple-kubernetes-webhook)
