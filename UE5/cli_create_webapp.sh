#!/bin/bash

# Define subscription
subscription=c42c6aa8-3c10-40e5-a3ff-ba5843e3dda5

# set subscription 
az account set --subscription $subscription

# Create an App Service app with deployment from GitHub
# set -e # exit if error
# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
grplocation="westeurope"
resourceGroup="CLINF-GL_Kappel"
tag="deploy-github.sh"
gitrepo=https://github.com/mnestler-git/TM_westeurope.git 


#locations
locationwesteurope=westeurope
locationeastus=eastus
#this location can be used to check what result a client will get outside the geographical setup of the trafficmanager
locationjapan=japanwest

# Create a resource group.
echo "Creating $resourceGroup in "$grplocation"..."
az group create --name $resourceGroup --location "$grplocation" --tag $tag

#####################################
####Create West Europe Web App#######
#####################################

appServicePlan="appserviceplanwesteurope$randomIdentifier"
webappWestEurope="appWEU$randomIdentifier"


# Create an App Service plan in `S1` tier.
echo "Creating $appServicePlan"
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --sku S1 --location $locationwesteurope

# Create a web app.
echo "Creating $webappWestEurope"
az webapp create --name $webappWestEurope --resource-group $resourceGroup --plan $appServicePlan

# Deploy code from a private GitHub repository. 
az webapp deployment source config --branch master --manual-integration --name $webappWestEurope --repo-url $gitrepo --resource-group $resourceGroup




#################################
####Create East US Web App#######
#################################


gitrepo=https://github.com/mnestler-git/TM_eastuse.git 
appServicePlan="appserviceplaneastus$randomIdentifier"
webappEastUS="appEUS$randomIdentifier"

# Create an App Service plan in `S1` tier.
echo "Creating $appServicePlan"
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --sku S1 --location $locationeastus

# Create a web app.
echo "Creating $webappEastUS"
az webapp create --name $webappEastUS --resource-group $resourceGroup --plan $appServicePlan

# Deploy code from a private GitHub repository. 
az webapp deployment source config --branch master --manual-integration --name $webappEastUS --repo-url $gitrepo --resource-group $resourceGroup

##create two virtual machines in the two locations where the app service plans located
# username=mnestler
# password='1234QWERasdf'
# az vm create \
#   -n vm-westeurope \
#   -g $resourceGroup \
#   -l $locationwesteurope \
#   --image Win2019Datacenter \
#   --admin-username $username \
#   --admin-password $password \
#   --nsg-rule rdp

username=mnestler
password='1234QWERasdf'
az vm create \
  -n vm-japanwest \
  -g $resourceGroup \
  -l $locationjapan \
  --image Win2019Datacenter \
  --admin-username $username \
  --admin-password $password \
  --nsg-rule rdp
  
az vm create \
  -n vm-eastus \
  -g $resourceGroup \
  -l $locationeastus \
  --image Win2019Datacenter \
  --admin-username $username \
  --admin-password $password \
  --nsg-rule rdp    