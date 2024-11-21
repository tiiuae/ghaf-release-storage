#!/bin/bash

storage_account_name="ghafreleasesstorage"
container_name="\$web"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
destination_dir="$script_dir/prod_v"

if ! command -v azcopy &> /dev/null; then
  echo "Error: azcopy command not found. Please install azcopy."
  exit 1
fi

if ! command -v az &> /dev/null; then
  echo "Error: Azure CLI command not found. Please install Azure CLI."
  exit 1
fi

if az account show &> /dev/null; then
  echo "You are already logged in."
else
  az login --use-device-code
fi

end=$(date -u -d "2 hours" '+%Y-%m-%dT%H:%MZ')
sas_token=$(az storage container generate-sas --account-name $storage_account_name --name "\$web" --permissions acdlrw --expiry $end --output tsv)

azcopy cp "https://$storage_account_name.blob.core.windows.net/$container_name?$sas_token" "$destination_dir" --recursive=true --exclude-pattern="*.tar"

echo "Files copied successfully to $destination_dir"