# Pedrocf Azure CV Automated Release

Follow the steps above to release the Pedrocf's Azure CV

## Requirements

* Linux, WSL or Mac OS
* Make
* Docker Compose

## Steps

1. Clone this repo: `git clone https://github.com/frdvo/azure_cv_release.git`

1. Fill _config.tf with a unique name prefix, your Azure Cognitive Services end point and subscription key

1. Login to Azure: `make login`

1. Deploy: `make deploy` you will see your URL at the end

1. Clean: `make clean`
