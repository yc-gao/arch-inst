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

    sudo pacman -S --noconfirm xorg xorg-xinit xorg-xrandr xdotool xss-lock i3lock \
        notification-daemon libnotify bspwm sxhkd alacritty polybar rofi ranger flameshot picom

    sudo pacman -S --noconfirm fcitx-im fcitx-googlepinyin fcitx-configtool \
        man-db man-pages \
        firefox obsidian vlc \
        ffmpeg wget curl xclip ripgrep-all ctags openbsd-netcat unzip neovim jq nmap rsync lsof
}

custom() {
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME"/.oh-my-zsh
    cp "$HOME"/.oh-my-zsh/templates/zshrc.zsh-template "$HOME"/.zshrc
    cat "${self_dir}"/dotconfig/zshrc >> "$HOME"/.zshrc

    ln -sfT "${self_dir}"/dotconfig/zprofile "$HOME"/.zprofile
    ln -sfT "${self_dir}"/dotconfig/xinitrc "$HOME"/.xinitrc

    mkdir -p "$HOME"/Pictures
    cp -rf "${self_dir}"/dotconfig/Pictures/* "$HOME"/Pictures/

    for t in "${self_dir}"/dotconfig/config/*; do
        ln -sfT "${t}" "$HOME/.config/$(basename "${t}")"
    done

    ln -sfT "$(which nvim)" "$HOME"/.local/bin/vim
    ln -sfT "$(which ranger)" "$HOME"/.local/bin/ra

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

