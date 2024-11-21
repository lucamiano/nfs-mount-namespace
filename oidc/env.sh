export REALM=$3
export OIDC_SERVER='https://keycloak.192.168.49.2.nip.io/'
export OIDC_ISSUER_URL="${OIDC_SERVER}/realms/${REALM}"
export OIDC_CLIENT_ID=$4
export OIDC_TOKEN_ENDPOINT=$(curl -k "${OIDC_ISSUER_URL}/.well-known/openid-configuration" | jq -r '.token_endpoint')
export OIDC_USERINFO_ENDPOINT=$(curl -k "${OIDC_ISSUER_URL}/.well-known/openid-configuration" | jq -r '.userinfo_endpoint')
export K8S_USER=$1
export K8S_USER_PASS=$2

