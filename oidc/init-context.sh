kubectl config set-credentials ${K8S_USER} \
   --auth-provider=oidc \
   --auth-provider-arg=idp-issuer-url=${OIDC_ISSUER_URL} \
   --auth-provider-arg=client-id=${OIDC_CLIENT_ID} \
   --auth-provider-arg=refresh-token=${REFRESH_TOKEN} \
   --auth-provider-arg=id-token=${ID_TOKEN} \
   --auth-provider-arg=idp-certificate-authority=$HOME/Personal/oidc/keycloak-ca.crt

kubectl config set-context ${K8S_USER} \
--cluster=minikube \
--user=${K8S_USER} \
--namespace=default
