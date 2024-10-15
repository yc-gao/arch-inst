#!/bin/bash
set -e

self_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

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
    sudo pacman -S --noconfirm cifs-utils lvm2 mdadm

    sudo cp -r ./airootfs/* /
    sudo mkinitcpio -P
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

    sudo pacman -S --noconfirm \
        notification-daemon libnotify \
        xorg xorg-xinit xorg-xrandr \
        xss-lock i3lock \
        bspwm sxhkd alacritty polybar feh rofi flameshot picom

    sudo pacman -S --noconfirm \
        fcitx-im fcitx-googlepinyin fcitx-configtool \
        firefox obsidian \
        man-db man-pages \
        ffmpeg imagemagick vlc \
        ranger ueberzug ffmpegthumbnailer imv \
        xdotool xclip \
        wget curl neovim unzip \
        ripgrep-all ctags openbsd-netcat jq nmap rsync lsof

    yay -S --noconfirm ripdrag-git
}

custom() {
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME"/.oh-my-zsh
    cp "$HOME"/.oh-my-zsh/templates/zshrc.zsh-template "$HOME"/.zshrc
    cat "${self_dir}"/dotconfig/zshrc >>"$HOME"/.zshrc

    cat "${self_dir}"/dotconfig/xinitrc >"$HOME"/.xinitrc
    cat "${self_dir}"/dotconfig/xprofile >"$HOME"/.xprofile
    cat "${self_dir}"/dotconfig/zprofile >"$HOME"/.zprofile

    mkdir -p "$HOME"/Pictures
    cp -rf "${self_dir}"/dotconfig/Pictures/* "$HOME"/Pictures/

    mkdir -p "$HOME"/.local/bin
    ln -sfT "$(which nvim)" "$HOME"/.local/bin/vim
    ln -sfT "$(which ranger)" "$HOME"/.local/bin/ra

    ln -sft "$HOME/.config/" "${self_dir}"/dotconfig/config/*

    mkdir -p ~/.software
    wget -O - https://github.com/Kitware/CMake/releases/download/v3.29.3/cmake-3.29.3-linux-x86_64.tar.gz \
        | tar -C ~/.software -xz
    echo 'add_local "$HOME"/.software/cmake-3.29.3-linux-x86_64' >> ~/.zshrc

    mkdir -p ~/.software
    wget -O - https://nodejs.org/dist/v20.14.0/node-v20.14.0-linux-x64.tar.xz \
        | tar -C ~/.software -xJ
    echo 'add_local "$HOME"/.software/node-v20.14.0-linux-x64' >> ~/.zshrc
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

