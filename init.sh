#!/bin/bash
set -e
user="xundaoxd"

run_onroot() {
    cat ./assets/pacman.conf >> /etc/pacman.conf
    pacman -Syy
    pacman -S --noconfirm archlinuxcn-keyring

    pacman -S --noconfirm \
        fcitx-im fcitx-googlepinyin fcitx-configtool \
        firefox okular flameshot \
        xclip ripgrep-all ctags wget curl openbsd-netcat yay man-db man-pages

    pacman -S --noconfirm notification-daemon
    mkdir -p /usr/share/dbus-1/services
    cat ./assets/org.freedesktop.Notifications.service > org.freedesktop.Notifications.service

    pacman -S --noconfirm docker docker-compose
    systemctl enable docker
    usermod -aG docker $user

    pacman -S --noconfirm virt-manager dnsmasq qemu-full \
        && systemctl enable libvirtd \
        && usermod -aG libvirt,kvm $user \
        && sed -i '/^unix_sock_group/{s/#//}' /etc/libvirt/libvirtd.conf

}

run_nonroot() {
    sudo "$0"
    yay -S --noconfirm nvidia-container-toolkit
}

if [[ $USER == "$user" ]]; then
    run_nonroot
elif [[ $USER == "root" ]]; then
    run_onroot
else
    echo ""
fi

