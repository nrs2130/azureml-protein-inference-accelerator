#!/bin/bash
# cleanup.sh - destroy all resources created by this accelerator
RESOURCE_GROUP="<your-resource-group-name>"
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
