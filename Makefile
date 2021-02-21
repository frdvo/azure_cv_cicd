DOCKER ?= docker-compose run --rm
TAG ?= $(shell git rev-parse --short HEAD)
ARM_CLIENT_ID ?= $(shell cat .service_principal.json | $(DOCKER) jq -r .appId)
ARM_CLIENT_SECRET ?= $(shell cat .service_principal.json | $(DOCKER) jq -r .password)
ARM_SUBSCRIPTION_ID ?= $(shell cat .azure/azureProfile.json | $(DOCKER) jq -r  '.subscriptions | .[].id')
ARM_TENANT_ID ?= $(shell cat .service_principal.json | $(DOCKER) jq -r .tenant)
AZ_VARS ?= ARM_CLIENT_ID=$(ARM_CLIENT_ID) ARM_CLIENT_SECRET=$(ARM_CLIENT_SECRET) ARM_SUBSCRIPTION_ID=$(ARM_SUBSCRIPTION_ID) ARM_TENANT_ID=$(ARM_TENANT_ID)


azlogin:
	@echo "🔒🔒🔒 Azure Login..."
	@$(DOCKER) az login --use-device-code

azsp:
	@echo "🔑🔑🔑 Creating Service Principal..."
	@az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$(ARM_SUBSCRIPTION_ID)" > .service_principal.json

deploy: 
	@echo "🚢🚢🚢 Deploying..."
	@$(AZ_VARS) $(DOCKER) terraform init && $(AZ_VARS) $(DOCKER) terraform apply
	
clean:
	@echo "🧹🧹🧹 Cleaning..."
	@$(AZ_VARS) $(DOCKER) terraform destroy