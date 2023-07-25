#!/bin/bash
set -e

user="xundaoxd"

die() {
    echo "$@"
    exit 1
}

run_asroot() {
    sudo "$0" "$@"
}

archlinuxcn() {
    [[ $UID != 0 ]] && run_asroot archlinuxcn && return
    cat ./assets/pacman.conf >> /etc/pacman.conf
    pacman -Syy
    pacman -S --noconfirm archlinuxcn-keyring
    pacman -S --noconfirm yay
}

fcitx() {
    [[ $UID != 0 ]] && run_asroot fcitx && return
    pacman -S --noconfirm \
        fcitx-im fcitx-googlepinyin fcitx-configtool
}

notification() {
    [[ $UID != 0 ]] && run_asroot notification && return
    pacman -S --noconfirm notification-daemon
    mkdir -p /usr/share/dbus-1/services
    cat ./assets/org.freedesktop.Notifications.service > /usr/share/dbus-1/services/org.freedesktop.Notifications.service
}

docker() {
    if [[ $UID != 0 ]]; then
        run_asroot docker
        yay -S --noconfirm nvidia-container-toolkit
        return
    fi
    pacman -S --noconfirm docker docker-compose
    systemctl enable docker
    usermod -aG docker $user
}

virt() {
    [[ $UID != 0 ]] && run_asroot virt && return
    pacman -S --noconfirm virt-manager dnsmasq qemu-full \
        && systemctl enable libvirtd \
        && usermod -aG libvirt,kvm $user \
        && sed -i '/^unix_sock_group/{s/#//}' /etc/libvirt/libvirtd.conf
}

bspwm() {
    [[ $UID == 0 ]] && die "please init bspwm as $user"
    run_asroot pacman -S --noconfirm xorg xorg-xprop sddm bspwm sxhkd alacritty \
        i3lock xss-lock polybar picom rofi feh ranger mpv firefox okular flameshot \
        usbutils man-db man-pages \
        wget curl xclip ripgrep-all ctags openbsd-netcat unzip neovim
    run_asroot systemctl enable sddm

    mkdir -p /etc/X11/xorg.conf.d
    cat ./assets/50-mouse-acceleration.conf > /etc/X11/xorg.conf.d/50-mouse-acceleration.conf

    archlinuxcn
    fcitx
    notification
    docker
    virt
}

action="bspwm"
if (( $# > 0 )); then
    action="$1"
    shift
fi
${action} "$@"
