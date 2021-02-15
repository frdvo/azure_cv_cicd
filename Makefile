DOCKER ?= docker-compose run --rm aztf

login:
	@echo "🔒🔒🔒 Azure Login..."
	$(DOCKER) az login --use-device-code

deploy: 
	@echo "🚢🚢🚢 Deploying..."
	$(DOCKER) terraform init && $(DOCKER) terraform apply

clean:
	@echo "🧹🧹🧹 Cleaning..."
	$(DOCKER) terraform destroy

