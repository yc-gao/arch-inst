#!/bin/bash
set -e

# systemctl stop reflector
# reflector --verbose --country China --protocol http --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

esp_partition=/dev/nvme0n1p1
root_partition=/dev/nvme0n1p2

mkfs.ext4 -F ${root_partition}
mkfs.fat -F 32 ${esp_partition}

mount ${root_partition} /mnt
mkdir -p /mnt/boot/efi
mount ${esp_partition} /mnt/boot/efi

pacstrap /mnt base base-devel linux-lts linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

cp install.sh /mnt/root/
arch-chroot /mnt /root/install.sh
rm -rf  /mnt/root/install.sh

