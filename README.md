# nfs-pod-access-control

## Introduction
The aim of this project is to propose a way to control access to a remote NFS home directory mounted on a pod mapping NFS users with Kubernetes users.

### Requirements
* Minikube
* kubectl
* Go >=1.23 (optional)

#### Deploy cluster

To deploy the cluster run from project root directory:
```
./scripts/setup-oidc-cluster oidc-cluster
```
This will deploy a minikube cluster using oidc authentication for users using Keycloak.

Wait until the keycloak ingress is reachable and then configure the realm
```
./scripts/setup-keycloak
```
Once asked provide your keycloak ingress url https://KEYCLOAK_INGRESS.

This will configure a new realm named Kubernetes, a client k8s and three users: user1, user2, user3.

#### Deploy webhook
To deploy the webhook run from project root directory:
```
./scripts/setup-webhook
```
This will deploy the webhook in namespace nfs

#### Configure users and service account
In order to test the webhook we are going to create three namespaces for users: user1, user2, user3 and their respective roles and rolebindings for RBAC.

Also we are going to create a service account for each user in each namespace
```
./scripts/setup-account user1 user1
./scripts/setup-account user1 user2
./scripts/setup-account user1 user3

./scripts/setup-user user1 user1
./scripts/setup-user user1 user2
./scripts/setup-user user1 user3
```

#### Configuring access for users
Now it's time to set credentials for OIDC users in Kubernetes.
To do so we have to retrieve an access token from the Keycloak server.
```
./scripts/init-user-context oidc-cluster user1 123 user1
./scripts/init-user-context oidc-cluster user2 123 user2
./scripts/init-user-context oidc-cluster user3 123 user3
```

Every time the token is expired we have to repeat the process.

To hit it's health endpoint from your minikube machine:
```
## To retrieve webhook svc cluster ip
kubectl get svc -n nfs

minikube ssh
curl -k https://CLUSTER-IP:8443/health
OK
```

## Admission Logic
A set of validations and mutations are implemented in an extensible framework. Those happen on the fly when a pod is deployed and no further resources are tracked and updated (ie. no controller logic).

### Validating Webhooks
#### Implemented
- [uid validation](pkg/validation/uid_validator.go): validates that a pod contains the correct runAsUser option, UID has to map with the correct user/serviceAccount

### Mutating Webhooks
#### Implemented
- [mount home directory](pkg/mutation/mount_home_directory.go): inject runAsUser option inside pod, mapping UID with correct user in NFS home directory



## Acknowledgements

- [slackhq/simple-kubernetes-webhook](https://github.com/slackhq/simple-kubernetes-webhook)
- [use-keycloak-to-authenticate-and-authorize-users-in-kubernetes-with-oidc](https://medium.com/@guillem.riera/use-keycloak-to-authenticate-and-authorize-users-in-kubernetes-with-oidc-cc214a82a49c)
- [installing-che-on-minikube-keycloak-oidc](https://eclipse.dev/che/docs/stable/administration-guide/installing-che-on-minikube-keycloak-oidc/)
