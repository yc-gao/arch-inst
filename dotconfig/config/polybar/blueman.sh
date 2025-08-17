#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

print_info() {
    local device_paired="$(bluetoothctl devices Connected | grep '^Device' | cut -d' ' -f3-)"
    if [[ -n "${device_paired}" ]]; then
        printf " ${device_paired}"
    else
        printf " UnConnected"
    fi
}

case "${1:-}" in
    *)
        print_info
        ;;
esac
