#!/bin/bash
set -e

hostname='xundaoxd-pc'
user="xundaoxd"

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo -e 'en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8' >> /etc/locale.gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
locale-gen

echo $hostname > /etc/hostname

mkinitcpio -P

pacman -S --noconfirm grub efibootmgr
grub-install --efi-directory=/boot/efi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm nvidia-lts alsa-utils alsa-firmware pulseaudio pulseaudio-alsa pulseaudio-bluetooth

pacman -S --noconfirm plasma kde-applications fcitx-googlepinyin kcm-fcitx
systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth

pacman -Syy
pacman -S --noconfirm zsh git neovim python-pynvim firefox openssh

useradd -m -s /bin/zsh $user
usermod -aG wheel $user
EDITOR=nvim visudo

echo 'set root password.'
passwd

echo "set $user password."
passwd $user

