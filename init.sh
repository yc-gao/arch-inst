#!/bin/bash
set -e

pacman -S --noconfirm man-db man-pages

echo -e '[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch\n' >> /etc/pacman.conf \
    && pacman -Syy \
    && pacman -S --noconfirm archlinuxcn-keyring \
    && pacman -Syy \
    && pacman -S --noconfirm yay

pacman -S --noconfirm docker \
    && yay -S --noconfirm nvidia-container-toolkit \
    && systemctl enable docker \
    && usermod -aG docker xundaoxd

pacman -S --noconfirm xclip obsidian code qemu-full
