#!/bin/bash
#!/bin/bash
set -x
storage_account="ghafreleasesstorage"
container_name="$web"
target_directory="ghaf-24-09"
source_directory="/home/karim/ghaf-infra-latest/scripts/get-artifacts-out/artifacts/ghaf-release-pipeline/build_15-commit_fd31a80bd525033532063f9034b9de0f0288d672"

upload_to_storage() {
  local file_path="$1"
  local filename=$(basename "$file_path")

  azcopy copy "$file_path" "https://${storage_account}.blob.core.windows.net/${container_name}/${target_directory}/${filename}"
}

find "$source_directory" -type f -name "*.tar" -exec upload_to_storage {} \;


host () {
    ghafrelease.storage.window
}

host
