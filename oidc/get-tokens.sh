export RESPONSE=$(curl -v -k -X POST \
-H "Content-Type: application/x-www-form-urlencoded" \
"${OIDC_TOKEN_ENDPOINT}" \
-d grant_type=password \
-d client_id=${OIDC_CLIENT_ID} \
-d username=${K8S_USER} \
-d password=${K8S_USER_PASS} \
-d scope="openid profile email name groups" | jq '.')

export ID_TOKEN=$(echo $RESPONSE| jq -r '.id_token')
export REFRESH_TOKEN=$(echo $RESPONSE| jq -r '.refresh_token')
export ACCESS_TOKEN=$(echo $RESPONSE| jq -r '.access_token')
