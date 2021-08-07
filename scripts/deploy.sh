#!/usr/bin/env bash
. .env

kubectl cluster-info

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx


for server in $SERVERS
do
kubectl apply -f  ../"${server}"/deployments/
done

INGRESS_EXTERNAL=$(kubectl get service ingress-nginx-controller  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

az network dns zone create -g  "${RESOURCE_GROUP}" -n "${ZONE_NAME}"
for server in $SERVERS
do
az network dns record-set a add-record -n  $server -g "${RESOURCE_GROUP}" --zone-name "${ZONE_NAME}" --ipv4-address "${INGRESS_EXTERNAL}"
done
