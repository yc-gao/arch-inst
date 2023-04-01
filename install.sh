#!/bin/bash
set -e

esp_partition=/dev/nvme0n1p1
root_partition=/dev/nvme0n1p2

hostname='xundaoxd-pc'
user="xundaoxd"

prepare() {
    # systemctl stop reflector
    # reflector --verbose --country China --protocol http --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

    mkfs.ext4 -F ${root_partition}
    mkfs.fat -F 32 ${esp_partition}

    mount ${root_partition} /mnt
    mkdir -p /mnt/boot/efi
    mount ${esp_partition} /mnt/boot/efi

    pacstrap /mnt base base-devel linux-lts linux-firmware
    genfstab -U /mnt >> /mnt/etc/fstab

    cp install.sh /mnt/root/
    arch-chroot /mnt /root/install.sh install
    rm -rf  /mnt/root/install.sh
    umount -R /mnt
}

install() {
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    echo -e 'en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8' >> /etc/locale.gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf
    locale-gen

    echo $hostname > /etc/hostname

    mkdir -p /etc/modprobe.d
    echo "options hid_apple fnmode=0" >> /etc/modprobe.d/hid_apple.conf
    mkinitcpio -P

    pacman -S --noconfirm grub efibootmgr
    grub-install --efi-directory=/boot/efi --recheck
    grub-mkconfig -o /boot/grub/grub.cfg

    pacman -S --noconfirm nvidia-lts alsa-utils alsa-firmware pulseaudio pulseaudio-alsa pulseaudio-bluetooth bluez bluez-utils openssh
    systemctl enable bluetooth
    systemctl enable sshd

    pacman -S --noconfirm networkmanager \
        xorg xorg-xprop sddm bspwm sxhkd i3lock xss-lock polybar picom alacritty rofi feh ranger \
        notification-daemon \
        fcitx-im fcitx-googlepinyin fcitx-configtool \
        zsh neovim xclip git unzip ripgrep-all ctags wget curl firefox okular flameshot \
        polkit sudo man-db man-pages
    systemctl enable sddm
    systemctl enable NetworkManager

    useradd -m -s /bin/zsh $user
    usermod -aG wheel $user
    EDITOR=nvim visudo

    echo "set $user password."
    passwd $user

    su - xundaoxd -c 'install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc'
    su - xundaoxd -c 'install -Dm644 /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc'
    su - xundaoxd -c 'sed -i "s/urxvt/alacritty/" ~/.config/sxhkd/sxhkdrc'
}

if [[ $# -eq 1 ]]; then
    $1
else
    prepare
fi

