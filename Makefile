ACR_NAME ?= \
	$(shell $(DOCKER) terraform -chdir=./tf_acr output acr_name \
	| $(DOCKER) jq -r)
ARM_CLIENT_ID ?= \
	$(shell cat .service_principal.json | $(DOCKER) jq -r .appId)
ARM_CLIENT_SECRET ?= \
	$(shell cat .service_principal.json | $(DOCKER) jq -r .password)
ARM_SUBSCRIPTION_ID ?= \
	$(shell cat .azure/azureProfile.json \
	| $(DOCKER) jq -r  '.subscriptions | .[].id')
ARM_TENANT_ID ?= \
	$(shell cat .service_principal.json | $(DOCKER) jq -r .tenant)
AZ_VARS ?= \
	ARM_CLIENT_ID='$(ARM_CLIENT_ID)' \
	ARM_CLIENT_SECRET='$(ARM_CLIENT_SECRET)' \
	ARM_SUBSCRIPTION_ID='$(ARM_SUBSCRIPTION_ID)' \
	ARM_TENANT_ID='$(ARM_TENANT_ID)'
CONTAINER_NAME ?= \
	azure_cv
DOCKER ?= \
	docker-compose run --rm -T
DOCKER_ACCESS_TOKEN ?= \
	$(shell cat .acrtoken.json | $(DOCKER) jq -r .accessToken)
DOCKER_LOGIN_SERVER ?= \
	$(shell cat .acrtoken.json | $(DOCKER) jq -r .loginServer)
END_POINT ?=
LOCATION ?= \
	australiaeast
NAME_PREFIX ?=
RG_NAME ?= \
	$(shell $(DOCKER) terraform -chdir=./tf_acr output rg_name \
	| $(DOCKER) jq -r)
SUBSCRIPTION_KEY ?=
TAG ?= \
	$(shell git rev-parse --short HEAD)
TF_ACI_VARS ?= \
	TF_VAR_docker_login_server='$(DOCKER_LOGIN_SERVER)' \
	TF_VAR_container_name='$(CONTAINER_NAME)' \
	TF_VAR_container_tag='$(TAG)' \
	TF_VAR_name_prefix='$(NAME_PREFIX)' \
	TF_VAR_end_point='$(END_POINT)' \
	TF_VAR_subscription_key='$(SUBSCRIPTION_KEY)' \
	TF_VAR_rg_name='$(RG_NAME)' \
	TF_VAR_location='$(LOCATION)' \
	TF_VAR_docker_access_token='$(DOCKER_ACCESS_TOKEN)' \
	TF_VAR_docker_login_server='$(DOCKER_LOGIN_SERVER)'
TF_ACR_VARS ?= \
	TF_VAR_name_prefix='$(NAME_PREFIX)' \
	TF_VAR_location='$(LOCATION)'


azlogin:
	@echo "🔒🔒🔒 Azure Login..."
	@$(DOCKER) az login --use-device-code

azsp:
	@echo "🔑🔑🔑 Creating Service Principal..."
	@$(DOCKER) az ad sp create-for-rbac --role="Contributor" \
	--scopes="/subscriptions/$(ARM_SUBSCRIPTION_ID)" > .service_principal.json

clean:
	@echo "🧹🧹🧹 Cleaning..."
	@$(AZ_VARS) $(TF_ACI_VARS) $(DOCKER) terraform -chdir=./tf_aci destroy
	@$(AZ_VARS) $(TF_ACR_VARS) $(DOCKER) terraform -chdir=./tf_acr destroy

build:
	@echo "🏷️📦🏗️Building and tagging container..."
	@cd docker && docker build -t ${DOCKER_LOGIN_SERVER}/${CONTAINER_NAME}:${TAG} .

deploy: publish deploy-aci

deploy-aci: 
	@echo "🚢🚢🚢 Deploying..."
	@$(AZ_VARS) $(DOCKER) terraform -chdir=./tf_aci init && $(AZ_VARS) \
	$(TF_ACI_VARS) $(DOCKER) terraform -chdir=./tf_aci apply -auto-approve

deploy-acr: 
	@echo "📦📦📦 Create ACR..."
	@$(TF_ACR_VARS) $(DOCKER) terraform -chdir=./tf_acr init && $(AZ_VARS) \
	$(TF_ACR_VARS) $(DOCKER) terraform -chdir=./tf_acr apply -auto-approve

dockerlogin: dockercredentials
	@echo "🐳 Docker Login to ACR.."
	@docker login ${DOCKER_LOGIN_SERVER} -u 00000000-0000-0000-0000-000000000000 \
	-p ${DOCKER_ACCESS_TOKEN}

dockercredentials:
	@echo "💳🐳 Getting Docker Credentials..."
	@$(DOCKER) az acr login -n $(ACR_NAME) --expose-token > .acrtoken.json

dockerpull:
	@echo "🐋⬇ Pulling Docker Containers..."
	@ docker-compose pull

prepare: dockerpull azlogin azsp deploy-acr dockerlogin

publish:
	@echo "🚀📦⛅Pushing container..."
	docker push ${DOCKER_LOGIN_SERVER}/${CONTAINER_NAME}:${TAG}

test:
	@echo "🧪🧪🧪 Testing..."
	@echo "Access the application on http://0.0.0.0:5000/upload-image"
	@docker run -p 5000:5000 --rm -e SUBSCRIPTION_KEY=${SUBSCRIPTION_KEY} \
	-e END_POINT=${END_POINT} \
	${DOCKER_LOGIN_SERVER}/${CONTAINER_NAME}:${TAG} \
	python app.py run -h 0.0.0.0