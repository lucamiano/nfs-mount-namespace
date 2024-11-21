#!/bin/bash

## Add NFS user to Kubernetes
# Get the input arguments passed to the script (USERNAME, NAMESPACE, CONFIGMAP_NAME, and K8S_NAMESPACE)
USERNAME=$1
export GROUP=$2
export NAMESPACE=$3
CONFIGMAP_NAME=$4
USERID=$5

envsubst < dev/manifests/accounts/nfs-rbac.yaml | tee /dev/tty | kubectl apply -f -

# Patch configmap adding k8s_user-nfs_uid mapping
kubectl patch configmap $CONFIGMAP_NAME --patch "{\"data\": {\"$USERNAME\": \"$USERID\"}}"

# Print a success message to indicate the ConfigMap has been updated
echo "ConfigMap updated successfully with ${USERNAME}:${USERID}"
