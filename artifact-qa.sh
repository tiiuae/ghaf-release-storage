#!/bin/bash

# Verify artifact existence checker

# ANSI color codes
GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

# Base URL and dynamic artifact path
BASE_URL="https://ghaf-jenkins-controller-release.northeurope.cloudapp.azure.com/artifacts/ghaf-release-pipeline/build_2-commit_0f2927810dd0373fbdb8b672e9fb50e945ff5fa6/"
ARTIFACT_PATH="aarch64-linux.nvidia-jetson-orin-agx-debug/"

# Full URL
FULL_URL="${BASE_URL}${ARTIFACT_PATH}"

# Expected structure declaration
declare -A expected_structure=(
    ["nix-support/hydra-build-products"]=file
    ["nix-support/system"]=file
    ["scs/http_cache.sqlite"]=file
    ["scs/provenance.json"]=file
    ["scs/provenance.json.sig"]=file
    ["scs/sbom.cdx.json"]=file
    ["scs/sbom.csv"]=file
    ["scs/sbom.spdx.json"]=file
    ["scs/vulns.txt"]=file
    ["sd-image/nixos-image-sd-card-25.05.20250114.eb62e6a-aarch64-linux.img.zst"]=file
    ["sd-image/nixos-image-sd-card-25.05.20250114.eb62e6a-aarch64-linux.img.zst.sig"]=file
    ["test-results/Robot-Framework/test-suites/bat/log.html"]=file
    ["test-results/Robot-Framework/test-suites/bat/output.xml"]=file
    ["test-results/Robot-Framework/test-suites/bat/report.html"]=file
    ["test-results/Robot-Framework/test-suites/boot/log.html"]=file
    ["test-results/Robot-Framework/test-suites/boot/output.xml"]=file
    ["test-results/Robot-Framework/test-suites/boot/report.html"]=file
    ["test-results/Robot-Framework/test-suites/turnoff/log.html"]=file
    ["test-results/Robot-Framework/test-suites/turnoff/output.xml"]=file
    ["test-results/Robot-Framework/test-suites/turnoff/report.html"]=file
    ["esp.offset"]=file
    ["esp.size"]=file
    ["root.offset"]=file
    ["root.size"]=file
)

# Ensure URL ends with /
[[ "$FULL_URL" != */ ]] && FULL_URL="${FULL_URL}/"

# Track missing files
declare -a missing_files=()

# Hold for 3 seconds and announce the artifact path
echo "Checking artifact in ${ARTIFACT_PATH}..."
sleep 6

# Verify each artifact
for artifact in "${!expected_structure[@]}"; do
    full_url="${FULL_URL}${artifact}"
    
    echo -n "Checking ${artifact}... "
    
    if wget --spider --timeout=10 --tries=2 "$full_url" 2>/dev/null; then
        echo -e "${GREEN}✓ Found${RESET}"
    else
        echo -e "${RED}✗ Missing${RESET}"
        missing_files+=("$artifact")
    fi
done

# Print summary
echo -e "\nVerification complete:"
if [ ${#missing_files[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All expected artifacts present!${RESET}"
else
    echo -e "${RED}❌ Missing artifacts:${RESET}"
    printf '  - %s\n' "${missing_files[@]}"
    exit 1
fi