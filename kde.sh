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
    sudo pacman -S --noconfirm plasma-meta kde-applications-meta kde-pim-meta
    sudo systemctl enable sddm

    sudo pacman -S --noconfirm curl wget neovim
}

custom() {
    git clone --depth 1 git@github.com:xundaoxd/dotfiles.git "${opt_wdir}/dotfiles"
    (cd "${opt_wdir}/dotfiles" && ./install.sh -f init install_osh install_nvim install_cmake install_nodejs install_ssh)
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

