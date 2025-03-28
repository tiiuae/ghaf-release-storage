#!/bin/bash

check_dependencies() {
  if ! command -v azcopy &> /dev/null; then
    echo "Error: azcopy command not found. Please install azcopy."
    exit 1
  fi
  if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI command not found. Please install Azure CLI."
    exit 1
  fi
}

azure_login() {
  if az account show &> /dev/null; then
    echo "You are logged in."
  else
    az login --use-device-code
  fi
}

get_release_tag_name() {
  while true; do
    read -p "Please enter the Release tag name (e.g., ghaf-24-09-8): " release_tag_name_dir
    if [[ -z "$release_tag_name_dir" || "$release_tag_name_dir" != ghaf-* ]]; then
      echo "Release tag name must start with 'ghaf' and cannot be empty. Please enter a valid name."
      continue
    fi
    
    if az storage blob list --account-name "$storage_account_name" --container-name "\$web" --prefix "$release_tag_name_dir/files/" --output tsv | grep -q "$release_tag_name_dir/files/"; then
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
}

create_local_release_dir() {
  local_release_dir="$release_tag_name_dir/files"
  if [ ! -d "$local_release_dir" ]; then
    mkdir -p "$local_release_dir"
    echo "Created local directory: $local_release_dir"
  fi
}

generate_html_files() {
  # Gen HTML
  sed "s|{{RELEASE_TAG}}|$release_tag_name_dir|g; s|{{DEPLOY_DATE}}|$deploy_date|g" "$template_dir/index.html" > "$local_release_dir/index.html"
  for file in "$source_dir"/*.tar "$source_dir"/*.tar.xz; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      sed -i "/<h1>$release_tag_name_dir<\/h1>/a <div class=\"report\">\n    <h3 class=\"report-title\"><a href=\"/$release_tag_name_dir/files/$filename\">$filename</a></h3>\n    <p class=\"report-date\">$deploy_date</p>\n</div>" "$local_release_dir/index.html"
    fi
  done

  # Generate Binary
  sed "s|{{RELEASE_TAG}}|$release_tag_name_dir|g" "$template_dir/binary-verification.html" > "$local_release_dir/signature-verification-of-binary-image.html"

  # Generate provenance
  sed "s|{{RELEASE_TAG}}|$release_tag_name_dir|g" "$template_dir/provenance-verification.html" > "$local_release_dir/signature-verification-of-provenance-file.html"
}

upload_html_files() {
  azcopy cp "$local_release_dir/*.html" "https://$storage_account_name.blob.core.windows.net/$container_name_code/?$sas_token" --recursive=true --overwrite=true
}

upload_artifacts() {
  if [ -n "$(ls -A "$source_dir"/*.tar 2>/dev/null)" ] || [ -n "$(ls -A "$source_dir"/*.tar.xz 2>/dev/null)" ]; then
    azcopy cp "$source_dir/*.tar" "https://$storage_account_name.blob.core.windows.net/$container_name?$sas_token" --recursive=true --overwrite=true
    azcopy cp "$source_dir/*.tar.xz" "https://$storage_account_name.blob.core.windows.net/$container_name?$sas_token" --recursive=true --overwrite=true
  fi
}