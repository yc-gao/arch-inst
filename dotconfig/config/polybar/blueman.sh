#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

print_info() {
    local device_paired="$(bluetoothctl devices Paired | cut -d' ' -f3-)"
    if [[ -n "${device_paired}" ]]; then
        printf "Paired ${device_paired}"
    else
        printf "UnPaired"
    fi
}

case "${1:-}" in
    *)
        print_info
        ;;
esac
