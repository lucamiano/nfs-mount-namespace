# Execute the script in the current shell with source

token=$(echo "$(kubectl describe secret test-secret -n nfs)" | grep "token:" | awk '{print $2}')
export TEST_TKN=$token

token=$(echo "$(kubectl describe secret dev-secret -n nfs)" | grep "token:" | awk '{print $2}')
export DEV_TKN=$token

token=$(echo "$(kubectl describe secret prod-secret -n nfs)" | grep "token:" | awk '{print $2}')
export PROD_TKN=$token

echo "DEV_TKN = ${DEV_TKN}"
echo "TEST_TKN = ${TEST_TKN}"
echo "PROD_TKN = ${PROD_TKN}"