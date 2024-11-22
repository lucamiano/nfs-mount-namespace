#!/bin/bash

# Execute the script in the current shell with source

USERNAME=$1
NAMESPACE=$2
TOKEN=$3
CLUSTER=$4

kubectl config set-credentials ${USERNAME} --token=${TOKEN}
kubectl config set-context ${USERNAME} --cluster=${CLUSTER} --user=${USERNAME} --namespace=${NAMESPACE}
