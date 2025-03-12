#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

# Color
GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

show_help() {
    echo "Usage: $0 <URL>"
    echo
    echo "This script checks for the presence of expected files and folders at the specified URL."
    echo
    echo "Arguments:"
    echo "  URL   The base URL where the artifacts are located."
    echo
    echo "Example:"
    echo "  $0 https://example.com/artifacts/path/"
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

if [ -z "$1" ]; then
    echo -e "${RED}Error: No URL provided.${RESET}"
    show_help
    exit 1
fi

FULL_URL="$1"

[[ "$FULL_URL" != */ ]] && FULL_URL="${FULL_URL}/"

# Check if reachable
if ! curl --head --silent --fail "$FULL_URL" > /dev/null; then
    echo -e "${RED}Error: The URL is not reachable or the server is down.${RESET}"
    exit 1
fi

declare -A expected_files=(
    ["scs/provenance.json"]=file
    ["scs/provenance.json.sig"]=file
    ["scs/sbom.cdx.json"]=file
    ["scs/sbom.csv"]=file
    ["scs/sbom.spdx.json"]=file
    ["scs/vulns.txt"]=file
    ["test-results/Robot-Framework/test-suites/bat/log.html"]=file
    ["test-results/Robot-Framework/test-suites/bat/output.xml"]=file
    ["test-results/Robot-Framework/test-suites/bat/report.html"]=file
    ["test-results/Robot-Framework/test-suites/relayboot/log.html"]=file
    ["test-results/Robot-Framework/test-suites/relayboot/output.xml"]=file
    ["test-results/Robot-Framework/test-suites/relayboot/report.html"]=file
    ["test-results/Robot-Framework/test-suites/relay-turnoff/log.html"]=file
    ["test-results/Robot-Framework/test-suites/relay-turnoff/output.xml"]=file
    ["test-results/Robot-Framework/test-suites/relay-turnoff/report.html"]=file
)

# Img files for check   
image_files=("nixos.img.zst" "nixos.img.zst.sig" "disk1.raw.zst" "disk1.raw.zst.sig" "*.img.zst" "*.img.zst.sig")
image_found_count=0  
image_found=()  

declare -a missing_files=()

check_file() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
        echo -e "${GREEN}✓ Found${RESET}"
        return 0
    else
        return 1
    fi
}

check_expected_files() {
    for file in "${!expected_files[@]}"; do
        local full_url="${FULL_URL}${file}"
        echo -n "Checking ${file}... "
        if ! check_file "$full_url"; then
            echo -e "${RED}✗ Missing${RESET}"
            missing_files+=("$full_url")
        fi
    done
}

# Check image files
check_image_files() {
    for dir in "" "sd-image/"; do  
        local target_url="${FULL_URL}${dir}"
        local contents=$(curl --silent "$target_url")

        for img_file in "${image_files[@]}"; do
            if echo "$contents" | grep -qE "${img_file//\*/.*}"; then
                echo -e "Checking ${dir}${img_file}... ${GREEN}✓ Found${RESET}"
                image_found+=("${img_file}")
                ((image_found_count++))
            fi
        done
    done

    # Count missing
    if [ "$image_found_count" -lt 2 ]; then
        for img_file in "${image_files[@]}"; do
            if [[ ! " ${image_found[@]} " =~ " ${img_file} " ]]; then
                echo -e "Checking ${img_file}... ${RED}✗ Missing${RESET}"
                missing_files+=("${FULL_URL}${img_file}")
            fi
        done
    fi
}

print_summary() {
    echo -e "\nVerification complete:"
    if [ ${#missing_files[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All expected artifacts are present!${RESET}"
    else
        echo -e "${RED}❌ Missing Resources:${RESET}"
        printf '  - %s\n' "${missing_files[@]}"
        exit 1
    fi
}

main() {
    echo "Checking artifacts in ${FULL_URL}..."
    sleep 6

    check_expected_files
    check_image_files
    print_summary
}

main "$@"
