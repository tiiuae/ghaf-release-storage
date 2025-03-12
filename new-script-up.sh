#!/usr/bin/env bash

storage_account_name="ghafreleasesstorage"
container_name="\$web"
source_dir="/home/karim/ghaf-release-storage-tii/ghaf-releases-artifacts"

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

trap 'echo "Upload canceled."; exit 1' INT

while true; do
  read -p "Enter the directory name for upload (e.g., ghaf-24-09-8/files): " directory_name
  if [ -z "$directory_name" ]; then
    echo "Directory name cannot be empty. Please enter a valid name."
    continue
  fi
  container_name="\$web/$directory_name"
  
  if az storage blob list --account-name $storage_account_name --container-name "\$web" --prefix "$directory_name/" --output tsv | grep -q "$directory_name/"; then
    read -p "Directory already exists. Do you want to continue uploading to this directory? (yes/no): " choice
    if [ "$choice" == "yes" ]; then
      break
    else
      echo "Please choose another name."
    fi
  else
    echo "Directory does not exist. Continuing with the provided name."
    break
  fi
done

end=`date -u -d "2 hours" '+%Y-%m-%dT%H:%MZ'`
sas_token=$(az storage container generate-sas --account-name $storage_account_name --name "\$web" --permissions acdlrw --expiry $end --output tsv)

azcopy cp /dev/null "https://$storage_account_name.blob.core.windows.net/$container_name/?$sas_token"

azcopy cp "$source_dir/*.tar" "https://$storage_account_name.blob.core.windows.net/$container_name?$sas_token" --recursive=true

echo "Upload completed successfully to $container_name!"
