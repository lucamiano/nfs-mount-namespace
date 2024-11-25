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
./scripts/create-oidc-cluster oidc-cluster
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
./scripts/create-webhook
```
This will deploy the webhook in namespace nfs

To check everything is working correctly hit it's health endpoint from your minikube machine:
```
## To retrieve webhook svc cluster ip
kubectl get svc -n nfs
```
```
minikube --profile oidc-cluster ssh -- curl -k https://CLUSTER-IP/health
OK
```

#### Configure users and service account
In order to test the webhook we are going to create three namespaces for users: user1, user2, user3 and their respective roles and rolebindings for RBAC.

Also we are going to create a persistent volume pointing to NFS home directory and a pvc for each user in his namespace, to do so run the following script:

```
./scripts/setup-cluster
```

#### Configuring access for users
Now it's time to set credentials for OIDC users in Kubernetes.
To do so we have to retrieve an access token from the Keycloak server.
```
./scripts/init-user-context oidc-cluster user1 123 user1
./scripts/init-user-context oidc-cluster user2 123 user2
./scripts/init-user-context oidc-cluster user3 123 user3
```

Every time the token has expired we have to execute the script.

## Admission Logic
A set of validations and mutations are implemented in an extensible framework. Those happen on the fly when a pod is deployed and no further resources are tracked and updated (ie. no controller logic).

### Validating Webhooks
#### Implemented
- [uid validation](pkg/validation/uid_validator.go): validates that a pod contains the correct runAsUser option, UID has to map with the correct user/serviceAccount

### Mutating Webhooks
#### Implemented
- [mount home directory](pkg/mutation/mount_home_directory.go): inject runAsUser option inside pod, mapping UID with correct user in NFS home directory

## Test
In order to test the system some yaml files has been provided inside the folder tests
This yaml take as input some variable in order to deploy the resources using different use cases.
```text
USER = The name of the user that executes the kubectl apply.
NAMESPACE = The namespace in which to deploy the resource.
USER_ID = UID of the corresponding user in NFS.
SVC_ACC = The service account corresponding to the user.
```
To test validation webhook a *test-pod.yaml* has been provided in order to test the deployment of a pod.

- *test-deployment* to test the deployment of a pod using a deployment object.

To test mutating webhook two manifests have been provided:
- *test-pod.yaml* that doesn't use the runAsUser field, letting the webhook retrieving it from the user that made the request
- *test-deployment* to test the deployment of a pod using a deployment object, letting the webhook retrieve the runAsUser value from the ServiceAccount used by the pod, mapped to the user that made the request

In order to run the test export the previously defined variables and execute:
```
envsubst < PATH_TO_MANIFEST | kubectl apply -f -
```

## Acknowledgements

- [slackhq/simple-kubernetes-webhook](https://github.com/slackhq/simple-kubernetes-webhook)
- [use-keycloak-to-authenticate-and-authorize-users-in-kubernetes-with-oidc](https://medium.com/@guillem.riera/use-keycloak-to-authenticate-and-authorize-users-in-kubernetes-with-oidc-cc214a82a49c)
- [installing-che-on-minikube-keycloak-oidc](https://eclipse.dev/che/docs/stable/administration-guide/installing-che-on-minikube-keycloak-oidc/)
