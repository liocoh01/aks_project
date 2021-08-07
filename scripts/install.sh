#!/usr/bin/env bash
. .env
echo $REGISTRY

# ====================== LOGIN ==========================
if ! type "az" > /dev/null; then
    echo "[AZ-Login] AZ CLI not installed, installing..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi
echo "[AZ-Login] AZ CLI Installed, continuing"
az login --output table --query '[].{name: name, subscriptionId: id, isDefault: isDefault}'
# az account list --output table
echo "[AZ-Login] Select Subscription"
read -p "Subscription: " SUBSCRIPTION_ID
echo "[AZ-Login] Setting Subscription to $SUBSCRIPTION_ID"
az account set --subscription "$SUBSCRIPTION_ID"
echo "[AZ-Login] Logged in!"

az acr create --resource-group "${RESOURCE_GROUP}" --name "${REGISTRY}" --sku Basic

az acr login --name "${REGISTRY}"

for server in ${SERVERS}
do
docker build ../"${server}" -t "${REGISTRY}.azurecr.io"/"${server}":latest
docker push "${REGISTRY}.azurecr.io"/"${server}":latest
done

az account set --subscription="${SUBSCRIPTION_ID}"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"

aks-engine deploy --dns-prefix ${DNS_PREFIX} \
    --resource-group ${RESOURCE_GROUP} \
    --location "${LOCATION}" \
    --api-model kubernetes.json \
    --subscription-id "${SUBSCRIPTION_ID}" \
    --auto-suffix
