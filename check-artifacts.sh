#!/usr/bin/env bash

# SPDX-License-Identifier: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

set -e # exit immediately if a command fails
set -u # treat unset variables as an error and exit
set -o pipefail # exit if any pipeline command fails

# This script is a helper to verify the existence of artifacts in a URL

################################################################################

MYNAME=$(basename "$0")
RED='' NONE=''

################################################################################

usage () {
    echo "Usage: $MYNAME [-h] [-v] -u URL"
    echo ""
    echo "Verify the existence of artifacts in a URL"
    echo ""
    echo ""
    echo "Options:"
    echo " -h    Print this help message"
    echo " -v    Set the script verbosity to DEBUG"
    echo " -u    Target URL to verify artifacts"
    echo ""
    echo "Example:"
    echo ""
    echo "  ./$MYNAME -u https://ghaf-jenkins-controller-dev.azure.com/path/to/artifact/"
    echo ""
}

################################################################################

print_err () {
    printf "${RED}Error:${NONE} %b\n" "$1" >&2
}

argparse () {
    OPTIND=1; DEBUG="false"; URL="";
    while getopts "hvu:" copt; do
        case "${copt}" in
            h)
                usage; exit 0 ;;
            v)
                DEBUG="true" ;;
            u)
                URL="$OPTARG" ;;
            *)
                print_err "unrecognized option"; usage; exit 1 ;;
        esac
    done
    shift $((OPTIND-1))
    if [ -n "$*" ]; then
        print_err "unsupported positional argument(s): '$*'"; exit 1
    fi
    if [ -z "$URL" ]; then
        print_err "missing mandatory option (-u)"; usage; exit 1
    fi
}

verify_artifacts () {
    url="$1"
    artifacts=(
        "nixos-sd-image-25.05.20241119.23e89b7-aarch64-linux.img.zst"
        "nixos-sd-image-25.05.20241119.23e89b7-aarch64-linux.img.zst.sig"
        "Binary image signature file"
        "Verify image signature"
        "Flash script"
        "Provenance file"
        "Provenance signature file"
        "Verify signature"
        "SBOM files"
        "CDX"
        "SPDX"
        ".csv"
        "Test automation results"
        "Boot"
        "BAT"
        "PERF"
    )
    for artifact in "${artifacts[@]}"; do
        if ! curl --output /dev/null --silent --head --fail "$url/$artifact"; then
            print_err "missing artifact: '$artifact'"
            exit 1
        fi
    done
    echo "All artifacts verified successfully."
}

################################################################################

main () {
    # Colorize output if stdout is to a terminal (and not to pipe or file)
    if [ -t 1 ]; then
      RED='\033[1;31m'
      NONE='\033[0m'
    fi
    argparse "$@"
    if [ "$DEBUG" = "true" ]; then
        set -x
    fi
    verify_artifacts "$URL"
}

main "$@"

################################################################################