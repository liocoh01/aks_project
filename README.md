# Installation

installing a cluster with AKS Engine (`aks-engine`) and deploy services

## Prerequisites

The following prerequisites are required:

1. An [Azure Subscription][azure]
1. The [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
1. Docker
1. Helm
1. kubectl tool
1. eks engine
## Deploy your Cluster
```
cd scripts
```
Add the following to the cluster env variables based on your .env file,

```
SERVERS="server-a server-b"   #server folder names that you want to build and push to acr
REGISTRY=liorco.azurecr.io
LOCATION=westus2
RESOURCE_GROUP=liorco-test
DNS_PREFIX=liorco-test
ZONE_NAME=liorco300.site
```
install the cluster

Running this script will provision the following:
  1. Registry
  1. Build and push the images
  1. deploy the cluster with eks engine and install calico
```
./install.sh
```

When You now have a Kubernetes cluster with the (mostly complete) set of default configurations.

```sh
export KUBECONFIG=./_output/liorco-test-610d1fdf/kubeconfig/kubeconfig.westus2.json
```

Now you're ready to to deploy the servers and nginx to your cluster !
### Deploy
Running this script will provision the following:
  1. Deploy your servers manifest
  1. Create nginx ingress controller
  1. Add dns A records pointing to the ingress controller
  
```
./deploy.sh
```

After Deploy you should dee the following pods added:

```
NAMESPACE     NAME                                                 READY   STATUS    RESTARTS   AGE
default       ingress-nginx-controller-86d99778d-66rxg             1/1     Running   0          25h
default       server-a-68fbfffbd8-sjqx8                            1/1     Running   0          21h
default       server-b-694b58bcf7-h7hfj                            1/1     Running   0          21h
```

You are now ready to access the webservers !

##### Note we are using a network policy to block access from server-a to server-b from only from the inside

