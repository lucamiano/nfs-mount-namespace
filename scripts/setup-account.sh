export USERNAME=$1
export NAMESPACE=$2

envsubst < dev/manifests/accounts/namespace.yaml | kubectl apply -f -
envsubst < dev/manifests/accounts/serviceaccount.yaml | kubectl apply -f -
envsubst < dev/manifests/accounts/sa-rbac.yaml | kubectl apply -f -
envsubst < dev/manifests/accounts/sa-secret.yaml | kubectl apply -f -