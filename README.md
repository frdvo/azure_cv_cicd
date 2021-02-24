# Pedrocf Azure CV Automated Build and Release

Follow the steps above to Build and Release the Pedrocf's Azure CV

## Requirements

* Linux, WSL or Mac OS
* Make
* Docker Compose

## Steps


1. Clone this repo: `git clone https://github.com/frdvo/azure_cv_cicd.git` and go to the repo dir `cd azure_cv_cicd`

2. Copy and paste the following commands and replace the variables in your favourite text editor:

````bash
export NAME_PREFIX="Enter Name Prefix to use a unique resource name" 
export END_POINT="Enter your Azure Cognitive Services End Point"
export SUBSCRIPTION_KEY="Enter your Azure Cognitive Services SUBSCRIPTION_KEY"
export LOCATION="Your Azure Nearest Location eg: Australia East"

# If you are using AzureRM remote backend also fill up the following variables

export BACKEND_TYPE="remote"
export BACKEND_RG="Enter the Resource Group of your backend storage account"
export BACKEND_STORAGE_ACCOUNT="Enter your backend storage account name"
export BACKEND_CONTAINER="Enter your backend storage account container name"
export BACKEND_KEY="Enter your backend key, it will be prefixed acr and aci"
````

3. Copy and paste the text above in your terminal and press enter and run the following commands
4. `make prepare` to login to Azure, deploy ACR and configure your local Docker (Must run local only)
5. `make build` to build the container
6. `make test` to test the App container in your computer (Optional, and must run local only)
7. `make deploy` to publish the contatainer and deploy ACI
8. `make clean` to clean the resources. You have to confirm to destroy each resource (ACI and ACR, and must run local only)

If you are running from a CI/CD Pipeline you have to provide the following Service Principal as Environment Variables

````
	ARM_CLIENT_ID
	ARM_CLIENT_SECRET
	ARM_SUBSCRIPTION_ID
	ARM_TENANT_ID
````

