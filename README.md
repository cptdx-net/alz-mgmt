# alz-mgmt

## Modify the README.md file

~~~powershell
cd cptdx.net # [OPTIONAL] make sure you are in the subfolder in case the repo is a submodule of another one
git status
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
$branchName="new-readme-file"
git branch $branchName
# switch to the new branch
git checkout $branchName
~~~

## Init Terraform

### New branch

~~~powershell
$branchName="tf-backend-config"
git branch $branchName
# switch to the new branch
git checkout $branchName
~~~

### Terraform settings

At this point we should have run the github action CD action already once.
Therefore we expect that the Terraform state file already exist on the storage account.

> IMPORTANT: In case you did create an Service Principal and did create the corresponding variables, please make sure to assign your service principal the needed role on the storage account.

~~~powershell
# get the object Id of the currently logged in user
$objectId=az ad signed-in-user show --query id -o tsv
# switch to the subscription where the storage account is located
az account list --query "[?user.name=='ga2@cptdx.net']"
az account set -s bootstrap
$storageId=az storage account list -g "rg-alz-mgmt-state-germanywestcentral-001" --query "[0].id" -o tsv
# assign ourself the blob reader role for the corresponding storage account
az role assignment create --role "Storage Blob Data Reader" --assignee-object-id $objectId --scope $storageId --assignee-principal-type User
# verify if container exist
az storage container list --auth-mode login --account-name "stoalzmgmger001zjln" -o table
# verify if blob exist
az storage blob list --auth-mode login  --account-name "stoalzmgmger001zjln" -c "mgmt-tfstate" -o table
# switch back to our main subscription
az account set -s "sub-01"
~~~

#### terraform.tf

we need to add the current storage account as backend for the state file
Modify the main.tf file to change the firewall sku to basic.

~~~hcl
backend "azurerm" {
resource_group_name   = "<BACKEND_AZURE_RESOURCE_GROUP_NAME>"
storage_account_name  = "<BACKEND_AZURE_STORAGE_ACCOUNT_NAME>"
container_name        = "<BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME>"
key                   = "<BACKEND_AZURE_STORAGE_ACCOUNT_STATE_FILE_NAME>"
use_azuread_auth     = true
subscription_id      = "<vars.BACKEND_AZURE_STORAGE_ACCOUNT_SUBSCRIPTION_ID>"
tenant_id            = "<vars.BACKEND_AZURE_STORAGE_ACCOUNT_TENANT_ID>"
}
~~~

> NOTE: Please replace the placeholders with the actual values.

You can find most of the variables in the github repository variables.

~~~powershell
# list all github repository variables, show only name and value
gh variable list --json name,value
~~~

#### Run terraform

Init a local Terraform.

> IMPORTANT: You should never change the state file directly. Always use the corresponding github action. To ensure that changes to the TF state file are not done by accident, your User should only have the "Blob Reader" role on the storage account.

~~~powershell
terraform init
terraform plan -out=tfplan.01 -lock=false
terraform fmt
terraform validate
~~~

The ALZ Template does set the default "provider "azurerm"" blocks subscriptions inside the corresponding github action via environment variables. Therefore we will need to create the same variable on our local PC in case we like to run the terraform plan without the need to modify the terraform code.

~~~powershell
$subIdBootStrap=az account list --query "[?name=='bootstrap'].id" -o tsv
$env:ARM_SUBSCRIPTION_ID = $subIdBootStrap
terraform plan -out=tfplan.01 -lock=false 
~~~

### Commit and Pull requewst via github cli

~~~bash
# show me the current git branch
git branch --show-current
# get current git status
git status
# commit all your changes
git add .
git commit -m $branchName
git push --set-upstream origin $branchName
gh pr create --title $branchName --body $branchName --base main--base main
~~~

Approve the pull request and merge it via the web interface.

~~~bash
# switch back to main
git checkout main
# pull the changes from the remote main branch
git pull
~~~


~~~powershell
terraform init
az login --use-device-code
~~~


## Change Firewall SKU

> IMPORTANT: Basic does not work because of https://github.com/Azure/terraform-azurerm-hubnetworking/pull/79

### New branch change-fw-sku

~~~powershell
huhu
# show the current branch
git branch --show-current # should be main
$branchName="change-fw-sku-to-basic"
git branch $branchName
# switch to the new branch
git checkout $branchName
~~~

Modify the main.tf file to change the firewall sku to basic.

#### Commit and Pull requewst via github cli

~~~powershell
terraform fmt
terraform validate
~~~

Modify the main.tf file to change the firewall sku to basic.

~~~hcl
firewall = {
subnet_address_prefix = var.firewall_subnet_address_prefix
management_subnet_address_prefix = var.firewall_management_subnet_address_prefix
sku_tier              = "Basic"
sku_name              = "AZFW_VNet"
zones                 = ["1", "2", "3"]
default_ip_configuration = {
    public_ip_config = {
    zones = ["1", "2", "3"]
    name  = "pip-hub-${local.starter_location}"
    }
}
}
~~~

Define the corresponding variables inside the variables.tf file.
And set the values inside the terraform.tfvars.json

~~~powershell
terraform fmt
terraform validate
terraform plan -lock=false
~~~

### Commit and Pull requewst via github cli

~~~powershell
# get current git status
git status
# commit all your changes
git add .
git commit -m $branchName
git push --set-upstream origin $branchName
gh pr create --title $branchName --body $branchName --base main
~~~

Approve the pull request and merge it via the web interface.

~~~bash
# switch back to main
git checkout main
# pull the changes from the remote main branch
git pull
~~~

## Create LZ0

### New branch create-lz0

~~~bash
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
git branch create-lz0
# switch to the new branch
git checkout create-lz0
~~~

### Commit and Pull requewst via github cli

~~~bash
terraform init # because of lz vending module
terraform fmt
terraform validate
terraform plan -out=tfplan-create-lz0
# get current git status
git status
# commit all your changes
git add .
git commit -m "create-lz0"
git push --set-upstream origin create-lz0
gh pr create --title "create-lz0" --body "create-lz0" --base main
~~~

Approve the pull request and merge it via the web interface.

~~~bash
# switch back to main
git checkout main
# pull the changes from the remote main branch
git pull
~~~

## Create VPN Gateway

### New branch create-vpn-gateway   

~~~bash
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
git branch create-vpn-gw
# switch to the new branch
git checkout create-vpn-gw
~~~

### Commit and Pull requewst via github cli

~~~bash
terraform fmt
terraform validate
terraform plan -out=tfplan-create-vpn-gw
# get current git status
git status
# commit all your changes
git add .
git commit -m "create-vpn-gw"
git push --set-upstream origin create-vpn-gw
gh pr create --title "create-vpn-gw" --body "create-vpn-gw" --base main
~~~

Approve the pull request and merge it via the web interface.

~~~bash
# switch back to main
git checkout main
# pull the changes from the remote main branch
git pull
~~~

## Overwrite Policy NSG

### New branch overwrite-policy-nsg   

~~~bash
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
git branch overwrite-policy-nsg
# switch to the new branch
git checkout overwrite-policy-nsg
~~~

- Modify the policy definition to overwrite the policy for NSG.
- Add new Policy

~~~bash
code ./locals.alz.tf
code .terraform/modules/enterprise_scale/modules/archetypes/lib/policy_definitions/policy_definition_es_deny_subnet_without_nsg.json
~~~

### Commit and Pull requewst via github cli

~~~bash
terraform fmt
terraform validate
terraform plan -out=tfplan-overwrite-policy-nsg
# get current git status
git status
# commit all your changes
git add .
git commit -m "overwrite-policy-nsg"
git push --set-upstream origin overwrite-policy-nsg
gh pr create --title "overwrite-policy-nsg" --body "overwrite-policy-nsg" --base main
~~~

Approve the pull request and merge it via the web interface.

~~~bash
# switch back to main
git checkout main
# pull the changes from the remote main branch
git pull
~~~

## Assign RT DINE Policy to MG Online (Work in progress)

### New branch dine-assigment-rt-online

~~~bash
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
git branch dine-assigment-rt-online
# switch to the new branch
git checkout dine-assigment-rt-online
~~~

Modify the main.tf file to change the firewall sku to basic.

Create new archetype for online_landing_zone
~~~bash
cp lib/archetype_extension_es_landing_zones.tmpl.json lib/archetype_extension_es_online_landing_zones.tmpl.json
# create and modify the new archetype
code lib/archetype_extension_es_online_landing_zones.tmpl.json
# lookup DINE parameters
code .terraform/modules/enterprise_scale/modules/archetypes/lib/policy_definitions/policy_definition_es_deploy_custom_route_table.json
~~~


### Commit and Pull requewst via github cli

~~~bash
terraform init # because of lz vending module
terraform fmt
terraform validate
terraform plan -out=tfplan-dine-assigment-rt-online
terraform show tfplan-dine-assigment-rt-online
# get current git status
git status
# commit all your changes
git add .
git status
git commit -m "dine-assigment-rt-online"
git push --set-upstream origin dine-assigment-rt-online
gh pr create --title "dine-assigment-rt-online" --body "dine-assigment-rt-online" --base main
~~~

Approve the pull request and merge it via the web interface.

~~~bash
# switch back to main
git checkout main
# pull the changes from the remote main branch
git pull
~~~

# Misc

## Github

We are going to provide some secretes and variables via the github build in secrets and variables feature.
> NOTE: If it comes to secret, this is a best practices, but I am unsure if variable should go into github. It would be better to keep them all at one place. Maybe the bicep parameter files are a better place. But in this case we would need to store resource ids in clear text.
~~~bash
# create private github repo
gh repo create alz-cptblue --private

# create github secret via gh cli for repo cptdazlz
gh secret set AZURE_CLIENT_ID -b $appid -e production
tid=$(az account show --query tenantId -o tsv)
gh secret set AZURE_TENANT_ID -b $tid -e production
subid=$(az account show --query id -o tsv)
gh secret set AZURE_SUBSCRIPTION_ID -b $subid -e production
gh secret set AZURE_OBJECT_ID -b $objectid -e production
gh secret list --env production

gh variable set MG_PREFIX -b alz --env production
gh variable set MG_TOPLEVEL_DISPLAYNAME -b "MyEdge Landing Zones" --env production
gh variable set LOCATION_GWC -b "germanywestcentral" --env production
# get log analytics workspace id
lawid=$(az monitor log-analytics workspace show -n alz-log-analytics -g rg-alz-logging-001 --query id -o tsv)
gh variable set LAW_ID_GWC -b $lawid --env production
pDnsRg=$(az group show -n rg-alz-vwan-001 --query id -o tsv)
gh variable set PDNS_RG_ID -b $pDnsRg --env production
gh variable list --env production

az account set -s sub-lz-bootstrap
az ad app federated-credential list --id 77eccaa5-34fc-45a8-98b9-5b7b95c84731
~~~