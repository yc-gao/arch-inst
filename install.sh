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

    pacstrap /mnt base base-devel linux linux-firmware
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

    pacman -S --noconfirm nvidia alsa-utils alsa-firmware pulseaudio pulseaudio-alsa pulseaudio-bluetooth

    pacman -S --noconfirm plasma kde-applications fcitx-googlepinyin kcm-fcitx
    systemctl enable sddm
    systemctl enable NetworkManager
    systemctl enable bluetooth

    pacman -Syy
    pacman -S --noconfirm zsh git neovim python-pynvim firefox openssh wget

    useradd -m -s /bin/zsh $user
    usermod -aG wheel $user
    EDITOR=nvim visudo

    echo "set $user password."
    passwd $user
}

if [[ $# -eq 1 ]]; then
    $1
else
    prepare
fi

