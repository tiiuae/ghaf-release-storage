#!/bin/bash

# Color codes for output
GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

show_help() {
    echo "Usage: $0 <URL>"
    echo
    echo "This script checks for the presence of expected files and folder at the specified URL."
    echo
    echo "Arguments:"
    echo "  URL   The base URL where the artifact is located."
    echo
    echo "Example:"
    echo "  $0 https://example.com/artifacts/path/"
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Check if URL is provided as an argument
if [ -z "$1" ]; then
    echo -e "${RED}Error: No URL provided.${RESET}"
    show_help
    exit 1
fi

# Base URL and artifact path
FULL_URL="$1"

# Ensure the URL correctly ends with a slash
[[ "$FULL_URL" != */ ]] && FULL_URL="${FULL_URL}/"

# checking for the presence of these files 
declare -A expected_files=(
    ["nix-support/hydra-build-products"]=file
    ["nix-support/system"]=file
    ["scs/http_cache.sqlite"]=file
    ["scs/provenance.json"]=file
    ["scs/provenance.json.sig"]=file
    ["scs/sbom.cdx.json"]=file
    ["scs/sbom.csv"]=file
    ["scs/sbom.spdx.json"]=file
    ["scs/vulns.txt"]=file
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

dynamic_patterns=("sd-image/*.img.zst" "sd-image/*.img.zst.sig")

declare -a missing_files=()

check_file() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
        echo -e "${GREEN}✓ Found${RESET}"
    else
        echo -e "${RED}✗ Missing${RESET}"
        missing_files+=("$url")
    fi
}

check_expected_files() {
    for file in "${!expected_files[@]}"; do
        local full_url="${FULL_URL}${file}"
        echo -n "Checking ${file}... "
        check_file "$full_url"
    done
}

# dynamic
check_dynamic_files() {
    for pattern in "${dynamic_patterns[@]}"; do
        echo -n "Checking ${pattern}... "
        if curl --silent --fail "${FULL_URL}${pattern}" > /dev/null; then
            echo -e "${GREEN}✓ Found${RESET}"
        else
            echo -e "${RED}✗ Missing${RESET}"
            missing_files+=("${FULL_URL}${pattern}")
        fi
    done
}


print_summary() {
    echo -e "\nVerification complete:"
    if [ ${#missing_files[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All expected artifacts present!${RESET}"
    else
        echo -e "${RED}❌ Missing artifacts:${RESET}"
        printf '  - %s\n' "${missing_files[@]}"
        exit 1
    fi
}


main() {
    echo "Checking artifacts in ${FULL_URL}..."
    sleep 6

    check_expected_files
    check_dynamic_files
    print_summary
}

main "$@"