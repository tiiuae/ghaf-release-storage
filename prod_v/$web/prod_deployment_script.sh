#!/bin/bash

storage_account_name="ghafreleasesstorage"
container_name="\$web"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$script_dir/ghaf-releases-artifacts"

if ! command -v azcopy &> /dev/null; then
  echo "Error: azcopy command not found. Please install azcopy."
  exit 1
fi

if ! command -v az &> /dev/null; then
  echo "Error: Azure CLI command not found. Please install Azure CLI."
  exit 1
fi

if az account show &> /dev/null; then
  echo "You are logged in."
else
  az login --use-device-code
fi

trap 'echo "Deployment canceled."; exit 1' INT

while true; do
  read -p "Please enter the Release tag name (e.g., ghaf-24-09-8): " release_tag_name
  if [[ -z "$release_tag_name" || "$release_tag_name" != ghaf-* ]]; then
    echo "Release tag name must start with 'ghaf' and cannot be empty. Please enter a valid name."
    continue
  fi
  container_name_code="\$web/$release_tag_name"
  release_tag_name="$release_tag_name/files"
  container_name="\$web/$release_tag_name"
  
  if az storage blob list --account-name $storage_account_name --container-name "\$web" --prefix "$release_tag_name/" --output tsv | grep -q "$release_tag_name/"; then
    read -p "Release tag name already exists. Do you want to continue redeploy to this Release tag? (yes/no): " choice
    if [ "$choice" == "yes" ]; then
      break
    else
      echo "Please choose another name."
    fi
  else
    read -p "Release tag name does not exist. Are you sure you want to continue with this release tag? (yes/no): " confirm_choice
    if [ "$confirm_choice" == "yes" ]; then
      echo "Continuing with the provided name."
      break
    else
      echo "Please modify the release tag name."
    fi
  fi
done

local_release_dir="$script_dir/$release_tag_name"
if [ ! -d "$local_release_dir" ]; then
  mkdir -p "$local_release_dir"
  echo "Created local directory: $local_release_dir"
fi

# List of required HTML files
required_files=("index.html" "signature-verification-of-binary-image.html" "signature-verification-of-provenance-file.html")

# Check and create dummy files if they do not exist
for file in "${required_files[@]}"; do
  if [ ! -f "$local_release_dir/$file" ]; then
    echo "<html><body><h1>Content</h1></body></html>" > "$local_release_dir/$file"
    echo "Created $file in $local_release_dir"
  fi
done

end=`date -u -d "2 hours" '+%Y-%m-%dT%H:%MZ'`
sas_token=$(az storage container generate-sas --account-name $storage_account_name --name "\$web" --permissions acdlrw --expiry $end --output tsv)

# Upload index.html to the root of the release tag directory
azcopy cp "$source_dir/index.html" "https://$storage_account_name.blob.core.windows.net/$container_name_code/index.html?$sas_token" --overwrite=true

# Upload .tar and .tar.xz files to the release tag directory if any exist
if [ -n "$(ls -A "$source_dir"/*.tar 2>/dev/null)" ] || [ -n "$(ls -A "$source_dir"/*.tar.xz 2>/dev/null)" ]; then
  azcopy cp "$source_dir/*.tar" "https://$storage_account_name.blob.core.windows.net/$container_name?$sas_token" --recursive=true --overwrite=true
  azcopy cp "$source_dir/*.tar.xz" "https://$storage_account_name.blob.core.windows.net/$container_name?$sas_token" --recursive=true --overwrite=true
fi

# Upload .html files from the local release directory to the root of the release tag directory
if [ -n "$(ls -A "$local_release_dir"/*.html 2>/dev/null)" ]; then
  azcopy cp "$local_release_dir/*.html" "https://$storage_account_name.blob.core.windows.net/$container_name_code/?$sas_token" --recursive=true --overwrite=true
fi

echo "Resources added successfully"