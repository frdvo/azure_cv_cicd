ACR_NAME ?= \
	$(shell $(AZ_VARS) $(DOCKER) terraform -chdir=./tf_acr \
	output acr_name | $(DOCKER) jq -r)
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
BACKEND_ACI_PLAN_URL ?= \
	https://${BACKEND_STORAGE_ACCOUNT}.blob.core.windows.net/${BACKEND_CONTAINER}/aci-${BACKEND_PLAN_KEY}
BACKEND_ACR_PLAN_URL ?= \
	https://${BACKEND_STORAGE_ACCOUNT}.blob.core.windows.net/${BACKEND_CONTAINER}/acr-${BACKEND_PLAN_KEY}
BACKEND_CONTAINER ?= \

BACKEND_KEY ?= \

BACKEND_PLAN_KEY ?= \

BACKEND_RG ?= \

BACKEND_STORAGE_ACCOUNT ?= \

BACKEND_TYPE ?= \

CONTAINER_NAME ?= \
	azure_cv
DOCKER ?= \
	docker-compose run --rm -T
DOCKER_ACCESS_TOKEN ?= \
	$(shell cat .acrtoken.json | $(DOCKER) jq -r .accessToken)
DOCKER_LOGIN_SERVER ?= \
	$(shell cat .acrtoken.json | $(DOCKER) jq -r .loginServer)
END_POINT ?= \

LOCATION ?= \
	australiaeast
NAME_PREFIX ?= \

RG_NAME ?= \
	$(shell $(AZ_VARS) $(DOCKER) terraform -chdir=./tf_acr output rg_name \
	| $(DOCKER) jq -r)
SUBSCRIPTION_KEY ?= \

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
.PHONY: azlogin

azsp:
	@echo "🔑🔑🔑 Creating Service Principal..."
	@$(DOCKER) az ad sp create-for-rbac --role="Contributor" \
	--scopes="/subscriptions/$(ARM_SUBSCRIPTION_ID)" > .service_principal.json
.PHONY: azsp


clean:
	@echo "🧹🧹🧹 Cleaning..."
	@$(AZ_VARS) $(TF_ACI_VARS) $(DOCKER) terraform -chdir=./tf_aci destroy
	@$(AZ_VARS) $(TF_ACR_VARS) $(DOCKER) terraform -chdir=./tf_acr destroy
.PHONY: clean

clean-force:
	@echo "💣💥 Cleaning Force..."
	@$(AZ_VARS) $(TF_ACI_VARS) $(DOCKER) terraform -chdir=./tf_aci destroy -auto-approve
	@$(AZ_VARS) $(TF_ACR_VARS) $(DOCKER) terraform -chdir=./tf_acr destroy -auto-approve
.PHONY: clean-force

build:
	@echo "🏷️📦🏗️Building and tagging container..."
	@cd docker && docker build -t ${DOCKER_LOGIN_SERVER}/${CONTAINER_NAME}:${TAG} .
.PHONY: build

deploy: publish deploy-aci
.PHONY: deploy

deploy-aci: 
	@echo "🚢🚢🚢 Deploying..."
	@if [ "${BACKEND_TYPE}" = "remote" ]; then \
		echo 'terraform {' > ./tf_aci/auto_backend.tf && \
		echo '  backend "azurerm" {' >> ./tf_aci/auto_backend.tf && \
		echo '      resource_group_name  = "${BACKEND_RG}"' \
			>> ./tf_aci/auto_backend.tf && \
		echo '      storage_account_name = "${BACKEND_STORAGE_ACCOUNT}"' \
			>> ./tf_aci/auto_backend.tf && \
		echo '      container_name       = "${BACKEND_CONTAINER}"' \
			>> ./tf_aci/auto_backend.tf && \
		echo '      key                  = "aci${NAME_PREFIX}${BACKEND_KEY}"' \
			>> ./tf_aci/auto_backend.tf && \
		echo '  }' >> ./tf_aci/auto_backend.tf && \
		echo '}' >> ./tf_aci/auto_backend.tf ;\
	fi
	@$(AZ_VARS) $(TF_ACI_VARS) $(DOCKER) terraform -chdir=./tf_aci init && $(AZ_VARS) \
	$(TF_ACI_VARS) $(DOCKER) terraform -chdir=./tf_aci apply -auto-approve
.PHONY: deploy-aci

deploy-acr: 
	@echo "📦📦📦 Create ACR..."
	@if [ "${BACKEND_TYPE}" = "remote" ]; then \
		echo 'terraform {' > ./tf_acr/auto_backend.tf && \
		echo '  backend "azurerm" {' >> ./tf_acr/auto_backend.tf && \
		echo '      resource_group_name  = "${BACKEND_RG}"' \
			>> ./tf_acr/auto_backend.tf && \
		echo '      storage_account_name = "${BACKEND_STORAGE_ACCOUNT}"' \
			>> ./tf_acr/auto_backend.tf && \
		echo '      container_name       = "${BACKEND_CONTAINER}"' \
			>> ./tf_acr/auto_backend.tf && \
		echo '      key                  = "acr${NAME_PREFIX}${BACKEND_KEY}"' \
			>> ./tf_acr/auto_backend.tf && \
		echo '  }' >> ./tf_acr/auto_backend.tf && \
		echo '}' >> ./tf_acr/auto_backend.tf && \
		$(AZ_VARS) $(DOCKER) az storage copy -s ${BACKEND_ACR_PLAN_URL} \
		 -d /workspace/acr-${BACKEND_PLAN_KEY} && \
		$(AZ_VARS) $(TF_ACR_VARS) $(DOCKER) terraform -chdir=./tf_acr init && \
		$(AZ_VARS) $(TF_ACR_VARS) $(DOCKER) terraform -chdir=./tf_acr apply \
		'/workspace/acr-${BACKEND_PLAN_KEY}'; else \
		$(AZ_VARS) $(TF_ACR_VARS) $(DOCKER) terraform -chdir=./tf_acr init && \
		$(AZ_VARS) $(TF_ACR_VARS) $(DOCKER) terraform \
		-chdir=./tf_acr apply -auto-approve; \
	fi
.PHONY: deploy-acr

dockerlogin: dockercredentials
	@echo "🐳 Docker Login to ACR.."
	@docker login ${DOCKER_LOGIN_SERVER} -u 00000000-0000-0000-0000-000000000000 \
	-p ${DOCKER_ACCESS_TOKEN}
.PHONY: dockerlogin

dockercredentials:
	@echo "💳🐳 Getting Docker Credentials..."
	@$(DOCKER) az acr login -n $(ACR_NAME) --expose-token > .acrtoken.json
.PHONY: dockercredentials

dockerpull:
	@echo "🐋⬇ Pulling Docker Containers..."
	@ docker-compose pull
.PHONY: dockerpull

plan-acr: 
	@echo "🚜🚜🚜 Plan ACR..."
	@if [ "${BACKEND_TYPE}" = "remote" ]; then \
		echo 'terraform {' > ./tf_acr/auto_backend.tf && \
		echo '  backend "azurerm" {' >> ./tf_acr/auto_backend.tf && \
		echo '      resource_group_name  = "${BACKEND_RG}"' \
			>> ./tf_acr/auto_backend.tf && \
		echo '      storage_account_name = "${BACKEND_STORAGE_ACCOUNT}"' \
			>> ./tf_acr/auto_backend.tf && \
		echo '      container_name       = "${BACKEND_CONTAINER}"' \
			>> ./tf_acr/auto_backend.tf && \
		echo '      key                  = "acr${NAME_PREFIX}${BACKEND_KEY}"' \
			>> ./tf_acr/auto_backend.tf && \
		echo '  }' >> ./tf_acr/auto_backend.tf && \
		echo '}' >> ./tf_acr/auto_backend.tf && \
	$(AZ_VARS) $(TF_ACR_VARS) $(DOCKER) terraform -chdir=./tf_acr init && $(AZ_VARS) && \
	$(AZ_VARS) $(TF_ACR_VARS) $(DOCKER) \
	terraform -chdir=./tf_acr plan -out='/workspace/acr-${BACKEND_PLAN_KEY}' && \
	$(AZ_VARS) $(DOCKER) az storage copy -s acr-${BACKEND_PLAN_KEY} -d \
	${BACKEND_ACR_PLAN_URL}; \
	fi
.PHONY: plan-acr

plan-aci: 
	@echo "🚜🚜🚜 Plan ACI..."
	@if [ "${BACKEND_TYPE}" = "remote" ]; then \
		echo 'terraform {' > ./tf_aci/auto_backend.tf && \
		echo '  backend "azurerm" {' >> ./tf_aci/auto_backend.tf && \
		echo '      resource_group_name  = "${BACKEND_RG}"' \
			>> ./tf_aci/auto_backend.tf && \
		echo '      storage_account_name = "${BACKEND_STORAGE_ACCOUNT}"' \
			>> ./tf_aci/auto_backend.tf && \
		echo '      container_name       = "${BACKEND_CONTAINER}"' \
			>> ./tf_aci/auto_backend.tf && \
		echo '      key                  = "aci${NAME_PREFIX}${BACKEND_KEY}"' \
			>> ./tf_aci/auto_backend.tf && \
		echo '  }' >> ./tf_aci/auto_backend.tf && \
		echo '}' >> ./tf_aci/auto_backend.tf && \
	$(AZ_VARS) $(TF_ACI_VARS) $(DOCKER) terraform -chdir=./tf_aci init && \
	$(AZ_VARS) $(TF_ACI_VARS) $(DOCKER) \
	terraform -chdir=./tf_aci plan -out='/workspace/aci-${BACKEND_PLAN_KEY}' && \
	$(AZ_VARS) $(DOCKER) az storage copy -s acr-${BACKEND_PLAN_KEY} -d \
	${BACKEND_ACI_PLAN_URL}; \
	fi
.PHONY: plan-aci

prepare: dockerpull azlogin azsp plan-acr deploy-acr dockerlogin
.PHONY: prepare

publish:
	@echo "🚀📦⛅Pushing container..."
	docker push ${DOCKER_LOGIN_SERVER}/${CONTAINER_NAME}:${TAG}
.PHONY: publish

test:
	@echo "🧪🧪🧪 Testing on local computer..."
	@echo ""
	@echo "--------------Access the application on:----------------------"
	@echo "----------\033[33m http://localhost:5000/upload-image\033[39m ----------------"
	@echo "----------------(Press CTRL+C to quit)------------------------"
	@echo "--------------------------------------------------------------"
	@echo ""
	@docker run -p 5000:5000 --rm -e SUBSCRIPTION_KEY=${SUBSCRIPTION_KEY} \
	-e END_POINT=${END_POINT} \
	${DOCKER_LOGIN_SERVER}/${CONTAINER_NAME}:${TAG}
.PHONY: test