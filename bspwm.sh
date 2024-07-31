#!/bin/bash
set -e

self_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

opt_wdir="${HOME}/Workdir"
user="ycgao"

err() {
    echo "$@" >&2
}

die() {
    err "$@"
    exit 1
}

base() {
    sudo pacman -Syu --noconfirm
    sudo cp -r -t / ${self_dir}/*
    mkinitcpio -P
}

aur() {
    git clone https://aur.archlinux.org/yay-bin.git
    (cd yay-bin && makepkg -si --noconfirm --needed)
    rm -rf yay-bin
}

docker() {
    sudo pacman -S --noconfirm docker docker-compose
    sudo systemctl enable docker
    sudo usermod -aG docker "${user}"
    yay -S --noconfirm nvidia-container-toolkit
}

desktop() {
    sudo pacman -S --noconfirm pipewire wireplumber pipewire-audio pipewire-alsa pipewire-pulse \
        bluez bluez-utils
    sudo systemctl enable bluetooth

    sudo pacman -S --noconfirm xorg xorg-xrandr sddm xdotool xss-lock i3lock \
        bspwm notification-daemon libnotify sxhkd alacritty polybar rofi ranger flameshot picom
    sudo systemctl enable sddm

    sudo pacman -S --noconfirm fcitx-im fcitx-googlepinyin fcitx-configtool \
        firefox obsidian vlc \
        man-db man-pages \
        ffmpeg wget curl xclip ripgrep-all ctags openbsd-netcat unzip neovim jq nmap rsync lsof

    echo '#!/usr/bin/env bash' > ~/.xprofile
    echo '# xrandr --output DP-0 --mode 2560x1440 --rate 144' >> ~/.xprofile
    echo 'export GTK_IM_MODULE=fcitx' >> ~/.xprofile
    echo 'export QT_IM_MODULE=fcitx' >> ~/.xprofile
    echo 'export XMODIFIERS=@im=fcitx' >> ~/.xprofile
}

custom() {
    git clone --depth 1 git@github.com:yc-gao/dotfiles.git "${opt_wdir}/dotfiles"
    (cd "${opt_wdir}/dotfiles" && ./install.sh -f)
}

main() {
    [[ "${UID}" == 0 ]] && die "please init bspwm use ${user}"

    base
    aur
    docker
    desktop
    custom
}

main

