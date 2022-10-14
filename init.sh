#!/bin/bash
set -e

pacman -S --noconfirm man-db man-pages

echo -e '[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch\n' >> /etc/pacman.conf \
    && pacman -Syy \
    && pacman -S --noconfirm archlinuxcn-keyring \
    && pacman -S --noconfirm yay

pacman -S --noconfirm docker \
    && yay -S --noconfirm nvidia-container-toolkit \
    && systemctl enable docker \
    && usermod -aG docker $USER

pacman -S --noconfirm xclip unzip

pacman -S --noconfirm virt-manager qemu-full \
    && sed -i 's/^#unix_sock_group/unix_sock_group/;s/^#unix_sock_rw_perms/unix_sock_rw_perms/;' /etc/libvirt/libvirtd.conf \
    && usermod -aG libvirt $USER

