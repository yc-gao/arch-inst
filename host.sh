#!/bin/bash

systemctl stop reflector
reflector --verbose --country China --protocol http --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

mkfs.fat /dev/nvme0n1p1
mkfs.ext4 -F /dev/nvme0n1p2
mkfs.ext4 -F /dev/nvme1n1p1

mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/efi /mnt/var
mount /dev/nvme0n1p1 /mnt/boot/efi
mount /dev/nvme1n1p1 /mnt/var

pacstrap /mnt base base-devel linux linux-firmware neovim zsh btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab
