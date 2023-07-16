#!/bin/bash
set -e

hostname='xundaoxd-pc'
user="xundaoxd"

rootdisk="/dev/nvme0n1p2"

# disk : mount point : mount options : format options
volumes=(
    "$rootdisk:/mnt:-o subvol=/@root:"
    "$rootdisk:/mnt/home:-o subvol=/@home:"
    "$rootdisk:/mnt/mnt/snapshots:-o subvol=/@snapshots:"
    "$rootdisk:/mnt/swap:-o subvol=/@swap:"
    "/dev/nvme0n1p1:/mnt/boot/efi::fat -F 32"
)

mnt_vols() {
    for vol in "${volumes[@]}"; do
        IFS=: read -r -a info <<< "$vol"
        [[ -n "${info[3]}" ]] && mkfs.${info[3]} "${info[0]}"
        mkdir -p "${info[1]}"
        [[ -n "${info[1]}" ]] && mount ${info[2]} "${info[0]}" "${info[1]}"
    done
}

prepare() {
    # systemctl stop reflector
    # reflector --verbose --country China --protocol http --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

    mkfs.btrfs -f -L rootdisk $rootdisk
    mount $rootdisk /mnt
    btrfs subvol create /mnt/@root
    btrfs subvol create /mnt/@home
    btrfs subvol create /mnt/@snapshots
    btrfs subvol create /mnt/@swap
    btrfs filesystem mkswapfile --size 64g /mnt/@swap/swapfile
    umount -R /mnt

    mnt_vols
    pacstrap /mnt base base-devel linux-lts linux-firmware btrfs-progs
    genfstab -U /mnt | sed -E 's/subvolid=[0-9]+//;s/,,/,/' >> /mnt/etc/fstab
    echo '/swap/swapfile none swap defaults 0 0' >> /mnt/etc/fstab
    cp install.sh /mnt/root/
    arch-chroot /mnt /root/install.sh install
    rm -rf  /mnt/root/install.sh
    umount -R /mnt

    mount $rootdisk /mnt
    ./snapshot init
    umount -R /mnt
}

install() {
    echo $hostname > /etc/hostname
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo -e 'en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8' >> /etc/locale.gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf
    locale-gen

    # kernel
    mkdir -p /etc/modprobe.d
    echo 'options hid_apple fnmode=2' > /etc/modprobe.d/hid_apple.conf
    mkinitcpio -P

    # boot
    pacman -S --noconfirm grub efibootmgr
    grub-install --efi-directory=/boot/efi --recheck
    grub-mkconfig -o /boot/grub/grub.cfg

    # video and sound
    pacman -S --noconfirm nvidia-lts alsa-utils alsa-firmware pulseaudio pulseaudio-alsa pulseaudio-bluetooth bluez bluez-utils
    systemctl enable bluetooth

    # network
    pacman -S --noconfirm networkmanager openssh
    systemctl enable NetworkManager
    systemctl enable sshd

    # misc and account
    pacman -S --noconfirm polkit sudo zsh git neovim

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

