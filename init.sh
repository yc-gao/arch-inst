#!/bin/bash
set -e

pacman -Syy \
    && pacman -S --noconfirm ttf-fira-code ttf-dejavu wqy-zenhei wqy-microhei \
    man-db man-pages \
    git firefox

echo -e '[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf \
    && pacman -Syy \
    && pacman -S --noconfirm archlinuxcn-keyring \
    && pacman -Syy \
    && pacman -S --noconfirm yay

pacman -Syy \
    && pacman -S --noconfirm docker \
    && yay -S --noconfirm nvidia-container-toolkit \
    && systemctl enable docker \
    && usermod -aG docker xundaoxd
