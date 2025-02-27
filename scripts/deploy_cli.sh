#!/bin/bash
# deploy_cli.sh - manually deploy the Azure ML accelerator using Azure CLI
# Prerequisites: Azure CLI logged in, user has Owner/Contributor on subscription.

# Edit these variables or pass them in as env vars
RESOURCE_GROUP="${RESOURCE_GROUP:-aml-protein-rg}"
LOCATION="${LOCATION:-eastus}"
TEMPLATE_FILE="infrastructure/main.bicep"
PARAM_FILE="infrastructure/main.parameters.json"

# 1. Create Resource Group
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# 2. Deploy Azure ML infrastructure via Bicep
az deployment group create --resource-group "$RESOURCE_GROUP" \
   --template-file "$TEMPLATE_FILE" --parameters "@$PARAM_FILE"

# 3. Register ML pipelines in the Azure ML workspace
# (Uses the Python script; ensure Azure CLI is logged in or use `az account set` to correct subscription)
WS_NAME=$(jq -r '.parameters.workspaceName.value' < $PARAM_FILE)
pip install azureml-core azureml-pipeline-core  # install Azure ML SDK
python scripts/register_pipelines.py --workspace "$WS_NAME" --resource-group "$RESOURCE_GROUP"
