#!/bin/bash
set -e

self_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
proj_dir=$(dirname "$self_dir")

wdir="$HOME/Workdir"
user="xundaoxd"

die() {
    echo "$@"
    exit 1
}

run_asroot() {
    sudo "$0" "$@"
}

aur() {
    if [[ $UID != 0 ]]; then
        git clone https://aur.archlinux.org/yay-bin.git
        (cd yay-bin && makepkg -si --noconfirm --needed)
        rm -rf yay-bin
    fi
}

docker() {
    if [[ $UID != 0 ]]; then
        run_asroot docker
        yay -S --noconfirm nvidia-container-toolkit
        return
    fi
    pacman -Syy
    pacman -S --noconfirm docker docker-compose
    systemctl enable docker
    usermod -aG docker $user
}

virt() {
    [[ $UID != 0 ]] && run_asroot virt && return
    pacman -Syy
    pacman -S --noconfirm virt-manager dnsmasq qemu-full \
        && systemctl enable libvirtd \
        && usermod -aG libvirt,kvm $user \
        && sed -i '/^unix_sock_group/{s/#//}' /etc/libvirt/libvirtd.conf
}

custom() {
    git clone git@github.com:xundaoxd/dotfiles.git "$wdir/dotfiles"
    (cd "$wdir/dotfiles" && ./install.sh -f)
    rm -rf ~/go
}

bspwm_desktop() {
    if [[ $UID != 0 ]]; then
        run_asroot bspwm_desktop
        yay -S --noconfirm daemonize
        cp -r "${proj_dir}/airootfs/home/xundaoxd" /home/
        return
    fi

    pacman -Syy

    pacman -S --noconfirm xorg sddm xdotool xss-lock i3lock \
        bspwm sxhkd alacritty polybar rofi ranger feh flameshot
    systemctl enable sddm

    pacman -S --noconfirm fcitx-im fcitx-googlepinyin fcitx-configtool

    pacman -S --noconfirm vlc evince firefox obsidian \
        usbutils ffmpeg \
        man-db man-pages wget curl xclip ripgrep-all ctags openbsd-netcat unzip neovim jq nmap rsync

    cp -r "${proj_dir}/airootfs/etc/modprobe.d" /etc/
    cp "${proj_dir}/airootfs/etc/sddm.conf" /etc/
    mkinitcpio -P
}

bspwm() {
    [[ $UID == 0 ]] && die "please init bspwm as $user"

    aur
    docker
    virt
    bspwm_desktop
    custom
}

while getopts 'w:' opt; do
    case $opt in
        w)      wdir="$OPTARG";;
        ?)      die "undefined opt: $opt";
    esac
done
shift $((OPTIND - 1))

bspwm "$@"
