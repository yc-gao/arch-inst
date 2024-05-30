#!/bin/bash
set -e

self_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

opt_wdir="${HOME}/Workdir"
user="xundaoxd"

err() {
    echo "$@" >&2
}

die() {
    err "$@"
    exit 1
}

base() {
    sudo pacman -Syu --noconfirm

    sudo pacman -S --noconfirm openssh
    sudo systemctl enable sshd

    git clone --depth 1 https://github.com/xundaoxd/arch-builder.git
    sudo cp -r "${self_dir}/arch-builder/airootfs/etc/modprobe.d" /etc/
    sudo mkinitcpio -P
    rm -rf arch-builder
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
        bspwm sxhkd alacritty polybar rofi ranger feh flameshot \
        fcitx-im fcitx-googlepinyin fcitx-configtool
    sudo systemctl enable sddm

    sudo pacman -S --noconfirm vlc evince firefox obsidian ffmpeg \
        man-db man-pages wget curl xclip ripgrep-all \
        ctags openbsd-netcat unzip neovim jq nmap rsync
}

custom() {
    git clone --depth 1 git@github.com:xundaoxd/dotfiles.git "${opt_wdir}/dotfiles"
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

