export USERNAME=$1
export NAMESPACE=$2

envsubst < dev/manifests/accounts/user-rbac.yaml | kubectl apply -f -