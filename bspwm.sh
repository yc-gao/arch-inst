#!/bin/bash
set -Eeuo pipefail

script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
script_name="$(basename "${BASH_SOURCE[0]}")"

info() {
    echo "Info: $*"
}

error() {
    echo "Error: $*" >&2
}

die() {
    error "Error: $*"
    exit 1
}

user="ycgao"

base() {
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm cifs-utils lvm2 mdadm

    sudo cp -r ./airootfs/* /
    sudo mkinitcpio -P
}

desktop() {
    sudo pacman -S --noconfirm pipewire wireplumber \
        pipewire-audio pipewire-alsa pipewire-pulse

    sudo pacman -S --noconfirm bluez bluez-utils blueman
    sudo systemctl enable bluetooth

    sudo pacman -S --noconfirm \
        xorg xorg-xrandr autorandr sddm \
        xss-lock i3lock \
        fcitx-im fcitx-googlepinyin fcitx-configtool \
        notification-daemon libnotify \
        bspwm sxhkd alacritty polybar feh rofi flameshot picom \
        ueberzug ffmpegthumbnailer ranger \
        xdotool xclip
    sudo systemctl enable sddm

    sudo pacman -S --noconfirm \
        firefox \
        man-db man-pages \
        ffmpeg imagemagick vlc imv \
        wget curl neovim unzip \
        ripgrep-all ctags openbsd-netcat jq nmap rsync lsof
}

podman() {
    sudo pacman -S --noconfirm podman netavark nvidia-container-toolkit \
        qemu-user-static qemu-user-static-binfmt
    echo 'unqualified-search-registries = ["docker.io"]' \
        | sudo tee /etc/containers/registries.conf.d/10-unqualified-search-registries.conf
    systemctl --user enable podman-restart.service
}

custom() {
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME"/.oh-my-zsh
    cp "$HOME"/.oh-my-zsh/templates/zshrc.zsh-template "$HOME"/.zshrc
    cat "${script_dir}"/dotconfig/zshrc >>"$HOME"/.zshrc

    cat "${script_dir}"/dotconfig/xprofile >"$HOME"/.xprofile

    mkdir -p "$HOME"/Pictures
    cp -rf "${script_dir}"/dotconfig/Pictures/* "$HOME"/Pictures/

    mkdir -p "$HOME"/.local/bin
    ln -sfT "$(which nvim)" "$HOME"/.local/bin/vim
    ln -sfT "$(which ranger)" "$HOME"/.local/bin/ra

    ln -sft "$HOME/.config/" "${script_dir}"/dotconfig/config/*

    mkdir -p "$HOME"/{Workdir,Tmp}
}

main() {
    (( "$UID" == 0 )) && die "init bspwm use ${user}"

    base
    desktop
    podman
    custom
}

main
