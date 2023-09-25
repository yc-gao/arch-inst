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

bspwm_desktop() {
    if [[ $UID != 0 ]]; then
        run_asroot bspwm_desktop
        yay -S --noconfirm daemonize
        return
    fi
    pacman -S --noconfirm notification-daemon
    mkdir -p /usr/share/dbus-1/services
    cat ./assets/org.freedesktop.Notifications.service > /usr/share/dbus-1/services/org.freedesktop.Notifications.service

    pacman -S --noconfirm xorg xorg-xprop sddm xdotool xss-lock i3lock \
        bspwm sxhkd alacritty polybar rofi ranger feh flameshot
    systemctl enable sddm

    pacman -S --noconfirm fcitx-im fcitx-googlepinyin fcitx-configtool

    pacman -S --noconfirm vlc evince firefox obsidian \
        usbutils ffmpeg \
        man-db man-pages wget curl xclip ripgrep-all ctags openbsd-netcat unzip neovim jq nmap
}

bspwm() {
    [[ $UID == 0 ]] && die "please init bspwm as $user"

    archlinuxcn
    docker
    virt
    bspwm_desktop
}

action="bspwm"
if (( $# > 0 )); then
    action="$1"
    shift
fi
${action} "$@"
