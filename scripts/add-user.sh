#!/bin/bash

## Add NFS user to Kubernetes
# Get the input arguments passed to the script (USERNAME, NAMESPACE, CONFIGMAP_NAME, and K8S_NAMESPACE)
USERNAME=$1
CONFIGMAP_NAME="nfs-pod-access-control-uid-mapping"
CONFIGMAP_NAMESPACE="nfs-pod-ac"
USERID=$2

# Patch configmap adding k8s_user-nfs_uid mapping
kubectl patch configmap -n $CONFIGMAP_NAMESPACE $CONFIGMAP_NAME --patch "{\"data\": {\"$USERNAME\": \"$USERID\"}}"
