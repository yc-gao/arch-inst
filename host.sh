#!/bin/bash
set -e

systemctl stop reflector
reflector --verbose --country China --protocol http --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

pacstrap /mnt base base-devel linux linux-firmware neovim zsh btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab
