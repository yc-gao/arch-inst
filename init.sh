#!/bin/bash
set -e
user="xundaoxd"

run_onroot() {
    cat >> /etc/pacman.conf << \EOF
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
EOF
    pacman -Syy
    pacman -S --noconfirm archlinuxcn-keyring

    pacman -S --noconfirm \
        fcitx-im fcitx-googlepinyin fcitx-configtool \
        firefox okular flameshot \
        xclip ripgrep-all ctags wget curl openbsd-netcat yay

    pacman -S --noconfirm notification-daemon
    mkdir -p /usr/share/dbus-1/services
    cat > /usr/share/dbus-1/services/org.freedesktop.Notifications.service << EOF
[D-BUS Service]
Name=org.freedesktop.Notifications
Exec=/usr/lib/notification-daemon-1.0/notification-daemon
EOF

    pacman -S --noconfirm qemu-full
    usermod -aG kvm $user
}

run_nonroot() {
    sudo "$0"
}

if [[ $USER == "$user" ]]; then
    run_nonroot
elif [[ $USER == "root" ]]; then
    run_onroot
else
    echo ""
fi

