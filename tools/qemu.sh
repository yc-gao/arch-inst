#!/usr/bin/env bash
set -e

qemu-system-x86_64 \
    -M q35 \
    -m 8G \
    -nic user \
    -drive if=pflash,format=raw,readonly=on,file=/opt/homebrew/share/qemu/edk2-x86_64-code.fd \
    -drive format=raw,file="$1"