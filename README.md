# Pedrocf Azure CV Automated Build and Release

Follow the steps above to release the Pedrocf's Azure CV

## Requirements

* Linux, WSL2 or Mac OS
* Make
* Docker Compose

## Steps

1. Clone this repo: `git clone https://github.com/frdvo/azure_cv_cicd.git` and go to the repo dir

2. Copy and paste the following commands and replace the values in your favourite text editor:

````bash
export NAME_PREFIX="Enter Name Prefix to use a unique resource name" 
export END_POINT="Enter your Azure Cognitive Services End Point"
export SUBSCRIPTION_KEY="Enter your Azure Cognitive Services SUBSCRIPTION_KEY"
export LOCATION="Your Azure Nearest Location eg: Australia East"
````

3. Copy and paste the text above in your terminal and press enter
4. run `make azlogin` to login to Azure
5. run `make azsp` to create a service principal
6. run `make deploy-acr` to create a Azure Container Registry
7. run `make dockerlogin` to login your local Docker to the ACR
8. run `make build` to build the application container
9. run `make publish` to send the container to your ACR
10. run `make deploy-aci` to deploy or update the container instance
11. run `make clean` to clean the resources
