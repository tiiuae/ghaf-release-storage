azcopy copy /home/karim/ghaf-infra-latest/scripts/get-artifacts-out/artifacts/ghaf-release-pipeline/build_15-commit_fd31a80bd525033532063f9034b9de0f0288d672 https://ghafreleasesstorage.blob.core.windows.net/$web/ghaf-24-09-01/

  environment.systemPackages = [
    pkgs.azure-storage-azcopy
  ];
