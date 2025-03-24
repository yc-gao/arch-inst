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

podman() {
    sudo pacman -S --noconfirm podman \
        passt netavark \
        qemu-user-static qemu-user-static-binfmt
    yay -S --noconfirm nvidia-container-toolkit
    systemctl --user enable podman.socket
    systemctl --user enable podman-restart.service
}
# docker() {
#     sudo pacman -S --noconfirm docker docker-compose
#     sudo systemctl enable docker
#     sudo usermod -aG docker "${user}"
#     yay -S --noconfirm nvidia-container-toolkit
# }

desktop() {
    sudo pacman -S --noconfirm pipewire wireplumber \
        pipewire-audio pipewire-alsa pipewire-pulse

    sudo pacman -S --noconfirm bluez bluez-utils bluetman
    sudo systemctl enable bluetooth

    sudo pacman -S --noconfirm \
        xorg xorg-xrandr sddm \
        notification-daemon libnotify \
        fcitx-im fcitx-googlepinyin fcitx-configtool \
        bspwm sxhkd alacritty polybar feh rofi flameshot picom ranger \
        xss-lock i3lock xdotool xclip
    sudo systemctl enable sddm

    sudo pacman -S --noconfirm \
        firefox \
        man-db man-pages \
        ffmpeg imagemagick vlc \
        ueberzug ffmpegthumbnailer imv \
        wget curl neovim unzip \
        ripgrep-all ctags openbsd-netcat jq nmap rsync lsof
}

custom() {
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME"/.oh-my-zsh
    cp "$HOME"/.oh-my-zsh/templates/zshrc.zsh-template "$HOME"/.zshrc
    cat "${self_dir}"/dotconfig/zshrc >>"$HOME"/.zshrc

    cat "${self_dir}"/dotconfig/xprofile >"$HOME"/.xprofile

    mkdir -p "$HOME"/Pictures
    cp -rf "${self_dir}"/dotconfig/Pictures/* "$HOME"/Pictures/

    mkdir -p "$HOME"/.local/bin
    ln -sfT "$(which nvim)" "$HOME"/.local/bin/vim
    ln -sfT "$(which ranger)" "$HOME"/.local/bin/ra

    ln -sft "$HOME/.config/" "${self_dir}"/dotconfig/config/*

    mkdir -p ~/.software
    wget -t 8 -O - https://nodejs.org/dist/v20.14.0/node-v20.14.0-linux-x64.tar.xz \
        | tar -C ~/.software -xJ
    echo 'add_local "$HOME"/.software/node-v20.14.0-linux-x64' >> ~/.zshrc
}

main() {
    [[ "${UID}" == 0 ]] && die "please init bspwm use ${user}"

    base
    aur
    podman
    # docker
    desktop
    custom
}

main

