#Set color values for printf"
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' #No Color

SUBSCRIPTION=""
AZURE_CLOUD_NAME=AzureUSGovernment

printf "${YELLOW}Signing in to Azure CLI${NC}\n"
printf "${RED}IMPORTANT: USE YOUR ACCOUNT TO SIGN IN. THE MANAGED IDENTITY WILL BE USED LATER IN THE SCRIPT${NC}\n"
az cloud set -n $AZURE_CLOUD_NAME
az config set core.login_experience_v2=off
az login --tenant  --output none
az account set -s $SUBSCRIPTION

printf "${YELLOW}Using the following parameters:${NC}\n"
printf "${LIGHTGREEN}Subscription:${YELLOW} $SUBSCRIPTION${NC}\n"
printf "${LIGHTGREEN}AzureCloud:${YELLOW} $AZURE_CLOUD_NAME${NC}\n"

LOCATION=<location>
printf "${LIGHTGREEN}Location:${YELLOW} $LOCATION${NC}\n"

RESOURCE_GROUP_NAME="<resource group name>"
printf "${LIGHTGREEN}Resource Group:${YELLOW} $RESOURCE_GROUP_NAME${NC}\n"

VNET_NAME="<vnet name>"
printf "${LIGHTGREEN}VNET:${YELLOW} $VNET_NAME${NC}\n"

VNET_RG_NAME="GIS-DEVTEST-INT-SOUTHWEST-NETWORK-RG"
SQL_SUBNET_NAME="<postgreSQL subnet name>"
printf "${LIGHTGREEN}POSTGRESQL subnet:${YELLOW} $SQL_SUBNET_NAME${NC}\n"

AKS_CLUSTER_NAME=<aks cluster name>
printf "${LIGHTGREEN}AKS Cluster Name:${YELLOW} $AKS_CLUSTER_NAME${NC}\n"

AKS_NODE_RESOURCE_GROUP_NAME="<aks node resource group name>"
printf "${LIGHTGREEN}AKS Node Resource Group:${YELLOW} $AKS_NODE_RESOURCE_GROUP_NAME${NC}\n"

AKS_SUBNET_NAME="<aks subnet>"
printf "${LIGHTGREEN}AKS subnet:${YELLOW} $AKS_SUBNET_NAME${NC}\n"

AZURE_CONTAINER_REGISTRY=<azure container registry name>
printf "${LIGHTGREEN}Azure Container Registry:${YELLOW} $AZURE_CONTAINER_REGISTRY${NC}\n"

UBUNTU_IMAGE_REPO="docker/library/ubuntu"
TES_IMAGE_REPO="cromwellonazure/tes"
TRIGGERSERVICE_IMAGE_REPO="cromwellonazure/triggerservice"
CROMWELL_IMAGE_REPO="broadinstitute/cromwell"

TES_IMAGE_NAME="$AZURE_CONTAINER_REGISTRY.azurecr.us/$TES_IMAGE_REPO:$(az acr repository show-tags --name $AZURE_CONTAINER_REGISTRY --repository $TES_IMAGE_REPO --top 1 --orderby time_desc --output tsv)"
printf "${LIGHTGREEN}TES image:${YELLOW} $TES_IMAGE_NAME${NC}\n"

TRIGGERSERVICE_IMAGE_NAME="$AZURE_CONTAINER_REGISTRY.azurecr.us/$TRIGGERSERVICE_IMAGE_REPO:$(az acr repository show-tags --name $AZURE_CONTAINER_REGISTRY --repository $TRIGGERSERVICE_IMAGE_REPO --top 1 --orderby time_desc --output tsv)"
printf "${LIGHTGREEN}Trigger Service image:${YELLOW} $TRIGGERSERVICE_IMAGE_NAME${NC}\n"

CROMWELL_IMAGE_NAME="$AZURE_CONTAINER_REGISTRY.azurecr.us/$CROMWELL_IMAGE_REPO:$(az acr repository show-tags --name $AZURE_CONTAINER_REGISTRY --repository $CROMWELL_IMAGE_REPO --top 1 --orderby time_desc --output tsv)"
printf "${LIGHTGREEN}Cromwell image:${YELLOW} $CROMWELL_IMAGE_NAME${NC}\n"

UBUNTU_IMAGE_NAME="$AZURE_CONTAINER_REGISTRY.azurecr.us/$UBUNTU_IMAGE_REPO:$(az acr repository show-tags --name $AZURE_CONTAINER_REGISTRY --repository $UBUNTU_IMAGE_REPO --top 1 --orderby time_desc --output tsv)"
printf "${LIGHTGREEN}Ubuntu image:${YELLOW} $UBUNTU_IMAGE_NAME${NC}\n"

AKS_DNS_ZONE_NAME=privatelink.usgovarizona.cx.aks.containerservice.azure.us
AKS_DNS_ZONE_ID=$(az network private-dns zone list -g <dns zone resource group> --query "[?name=='privatelink.usgovarizona.cx.aks.containerservice.azure.us'].id" --output tsv)

BATCH_NODE_SUBNET_NAME=<batch node subnet name>
BATCH_NODE_SUBNET_ID=$(az network vnet subnet show --resource-group $VNET_RG_NAME --vnet-name $VNET_NAME --name $BATCH_NODE_SUBNET_NAME --query id --output tsv)
printf "${LIGHTGREEN}Batch Node Subnet:${YELLOW} $BATCH_NODE_SUBNET_NAME${NC}\n"

STORAGE_ACCOUNT_NAME=<storage account name>
STORAGE_ACCOUNT_ID=$(az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --query id -o tsv)
printf "${LIGHTGREEN}Storage account:${YELLOW} $STORAGE_ACCOUNT_NAME${NC}\n"

MANAGED_IDENTITY_NAME=<uami name>
MANAGED_IDENTITY_RG_NAME=<uami resource group name>
printf "${LIGHTGREEN}Managed identity:${YELLOW} $MANAGED_IDENTITY_NAME${NC}\n"

MANAGED_IDENTITY_ID=$(az identity show --name $MANAGED_IDENTITY_NAME --resource-group $MANAGED_IDENTITY_RG_NAME --query id -o tsv)


BATCH_ACCOUNT_NAME=<batch account name>
BATCH_ACCOUNT=$(az batch account show --name $BATCH_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME --query name -o tsv)
printf "${LIGHTGREEN}Batch account:${YELLOW} $BATCH_ACCOUNT_NAME${NC}\n"

VNET_SUBNET_ID=$(az network vnet subnet show -g $VNET_RG_NAME --vnet-name $VNET_NAME --name $AKS_SUBNET_NAME --query id -o tsv)

LOG_ANALYTICS_WORKSPACE_NAME=<log analytics workspace name>
LOG_ANALYTICS_ARM_ID=$(az monitor log-analytics workspace show --name $LOG_ANALYTICS_WORKSPACE_NAME -g $RESOURCE_GROUP_NAME --query id -o tsv)
printf "${LIGHTGREEN}Log Analytics workspace:${YELLOW} $LOG_ANALYTICS_WORKSPACE_NAME${NC}\n"

COA_IDENTIFIER=vsmp

printf "${YELLOW}Deploying cromwell${NC}\n"

sleep 20s
./deploy-cromwell-on-azure-linux --SubscriptionId $SUBSCRIPTION \
--RegionName $LOCATION \
--AzureCloudName $AZURE_CLOUD_NAME \
--MainIdentifierPrefix $COA_IDENTIFIER  \
--StorageAccountName $STORAGE_ACCOUNT_NAME \
--PrivateNetworking true \
--BatchNodesSubnetId $BATCH_NODE_SUBNET_ID \
--DisableBatchNodesPublicIpAddress true \
--ResourceGroupName $RESOURCE_GROUP_NAME \
--VnetName $VNET_NAME \
--VnetResourceGroupName $VNET_RG_NAME \
--VmSubnetName $AKS_SUBNET_NAME \
--PostgreSqlSubnetName $SQL_SUBNET_NAME \
--HelmBinaryPath /usr/local/bin/helm \
--IdentityResourceId $MANAGED_IDENTITY_ID \
--AksNodeResourceGroupName $AKS_NODE_RESOURCE_GROUP_NAME \
--BatchAccountName $BATCH_ACCOUNT_NAME \
--LogAnalyticsArmId $LOG_ANALYTICS_ARM_ID \
--tesimagename $TES_IMAGE_NAME \
--triggerserviceimagename $TRIGGERSERVICE_IMAGE_NAME \
--CromwellImageName $CROMWELL_IMAGE_NAME \
--PrivatePSQLUbuntuImage $UBUNTU_IMAGE_NAME \
--PrivateTestUbuntuImage $UBUNTU_IMAGE_NAME \
--UserDefinedRouting true \
--AksPrivateDnsZoneResourceId $AKS_DNS_ZONE_ID \
--AksClusterName $AKS_CLUSTER_NAME \
--CreateMissing true \
--DebugLogging true

az logout
printf "${YELLOW}Logging in to Azure CLI with managed identity${NC}\n"
az login --identity --resource-id $MANAGED_IDENTITY_ID 
kubelogin convert-kubeconfig -l azurecli

printf "${YELLOW}Retrieving credentials for AKS cluster${NC}\n"
az aks get-credentials -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP_NAME --overwrite-existing
