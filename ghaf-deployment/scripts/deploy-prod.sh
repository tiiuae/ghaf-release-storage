#!/bin/bash


script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/utils.sh"


storage_account_name="ghafreleasesstorage"
container_name="\$web"
source_dir="$script_dir/../ghaf-releases-artifacts"
template_dir="$script_dir/../templates"
local_release_dir=""


check_dependencies


azure_login


trap 'echo "Deployment canceled."; exit 1' INT


get_release_tag_name
container_name_code="\$web/$release_tag_name_dir"
release_tag_name="$release_tag_name_dir/files"
container_name="\$web/$release_tag_name"


create_local_release_dir


deploy_date=$(date '+%Y-%m-%d')


generate_html_files


end=$(date -u -d "2 hours" '+%Y-%m-%dT%H:%MZ')
sas_token=$(az storage container generate-sas --account-name "$storage_account_name" --name "\$web" --permissions acdlrw --expiry "$end" --output tsv)


upload_html_files


upload_artifacts

echo "Resources added successfully"


