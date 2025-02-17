#!/bin/bash

# Color 
RED='\e[31m'
RESET='\e[0m'

show_help() {
    echo "Usage: $0 <BASE_URL>"
    echo
    echo "This script checks for the presence of expected files and folders at the specified base URL."
    echo
    echo "Arguments:"
    echo "  BASE_URL   The base URL where the artifact subdirectories are located."
    echo
    echo "Example:"
    echo "  $0 https://example.com/artifacts/path/"
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

if [ -z "$1" ]; then
    echo -e "${RED}Error: No base URL provided.${RESET}"
    show_help
    exit 1
fi

BASE_URL="$1"
[[ "$BASE_URL" != */ ]] && BASE_URL="${BASE_URL}/"

subdirectories=(
    "aarch64-linux.nvidia-jetson-orin-agx-debug/"
    "aarch64-linux.nvidia-jetson-orin-nx-debug/"
    "x86_64-linux.generic-x86_64-debug/"
    "x86_64-linux.lenovo-x1-carbon-gen11-debug/"
    "x86_64-linux.nvidia-jetson-orin-agx-debug-from-x86_64/"
    "x86_64-linux.nvidia-jetson-orin-nx-debug-from-x86_64/"
)

main() {
    for subdir in "${subdirectories[@]}"; do
        local full_url="${BASE_URL}${subdir}"
	echo
	echo "* Target: ${subdir}"
        sleep 2
	bash ./check-one-target.sh ${full_url}
    done
}

main "$@"
