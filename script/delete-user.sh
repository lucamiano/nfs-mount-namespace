#!/bin/bash

## Add NFS user to Kubernetes
export USERNAME=$1
export NAMESPACE=$2

envsubst < account/role.yaml | kubectl delete -f -
envsubst < account/serviceaccount.yaml | kubectl delete -f -
envsubst < account/rolebinding.yaml | kubectl delete -f -
envsubst < account/sa-secret.yaml | kubectl delete -f -