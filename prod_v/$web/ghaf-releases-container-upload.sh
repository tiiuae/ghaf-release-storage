#!/bin/bash

# Variables
STORAGE_ACCOUNT_NAME="ghafreleasesstorage"
CONTAINER_NAME="ghaf-releases-container"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FOLDER="$script_dir/prod_v"

# Check if azcopy is installed
if ! command -v azcopy &> /dev/null; then
  echo "Error: azcopy command not found. Please install azcopy."
  exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
  echo "Error: Azure CLI command not found. Please install Azure CLI."
  exit 1
fi

# Check if logged in to Azure
if az account show &> /dev/null; then
  echo "You are already logged in."
else
  az login --use-device-code
fi

# Generate SAS token
end=$(date -u -d "2 hours" '+%Y-%m-%dT%H:%MZ')
sas_token=$(az storage container generate-sas --account-name $STORAGE_ACCOUNT_NAME --name $CONTAINER_NAME --permissions acdlrw --expiry $end --output tsv)

# Upload the folder using azcopy
echo "Uploading $SOURCE_FOLDER to $CONTAINER_NAME..."
azcopy cp "$SOURCE_FOLDER" "https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/$CONTAINER_NAME?$sas_token" --recursive=true

if [ $? -eq 0 ]; then
    echo "Upload completed successfully."
else
    echo "Upload failed."
    exit 1
fi