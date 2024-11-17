#!/bin/bash

# Execute the script in the current shell with source

USERNAME=$1
NAMESPACE=$2

token=$(kubectl describe secret ${USERNAME}-secret -n ${NAMESPACE} | grep "token:" | awk '{print $2}')

echo $token