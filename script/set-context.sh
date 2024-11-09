#!/bin/bash

# Execute the script in the current shell with source

USERNAME=$1
NAMESPACE=$2
TOKEN=$3

kubectl config set-credentials ${USERNAME} --token=${TOKEN}
kubectl config set-context ${USERNAME} --cluster=cka-cluster --user=${USERNAME} --namespace=${NAMESPACE}