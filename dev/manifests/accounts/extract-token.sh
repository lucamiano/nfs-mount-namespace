# Execute the script in the current shell with source

token=$(echo "$(kubectl describe secret test-secret -n nfs)" | grep "token:" | awk '{print $2}')
export TEST_TOKEN=$token

token=$(echo "$(kubectl describe secret dev-secret -n nfs)" | grep "token:" | awk '{print $2}')
export DEV_TOKEN=$token

token=$(echo "$(kubectl describe secret prod-secret -n nfs)" | grep "token:" | awk '{print $2}')
export PROD_TOKEN=$token

echo "Tokens are TEST_TOKEN, DEV_TOKEN, PROD_TOKEN"