#!/bin/bash

## Add NFS user to Kubernetes
# Get the input arguments passed to the script (USERNAME, NAMESPACE, CONFIGMAP_NAME, and K8S_NAMESPACE)
export USERNAME=$1
export NAMESPACE=$2
CONFIGMAP_NAME=$3
USERID=$4

envsubst < dev/manifests/accounts/role.yaml | kubectl apply -f -
envsubst < dev/manifests/accounts/serviceaccount.yaml | kubectl apply -f -
envsubst < dev/manifests/accounts/rolebinding.yaml | kubectl apply -f -
envsubst < dev/manifests/accounts/sa-secret.yaml | kubectl apply -f -

# Patch configmap adding k8s_user-nfs_uid mapping
kubectl patch configmap $CONFIGMAP_NAME --patch "{\"data\": {\"$USERNAME\": \"$USERID\"}}"

# Print a success message to indicate the ConfigMap has been updated
echo "ConfigMap updated successfully with ${USERNAME}:${USERID}"
