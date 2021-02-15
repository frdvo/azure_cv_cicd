# Pedrocf Azure CV Automated Release

Follow the steps above to release the Pedrocf's Azure CV

## Requirements

* Linux, WSL2 or Mac OS
* Make
* Docker Compose

## Steps

1. Fill _config.tf with a unique name prefix, your Azure Cognitive Services end point and subscription key

1. Login to Azure with `make login`

1. Deploy with `make deploy` you will see your URL at the end

1. Clean with `make clean`