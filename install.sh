#!/bin/bash
set -e

self_path=$(realpath "${BASH_SOURCE[0]}")
self_dir=$(dirname "$self_path")

hostname='xundaoxd-pc'
user="xundaoxd"
user_passwd=""

rootdisk="/dev/nvme0n1p2"

# disk : format : mount point : mount options
volumes=(
    "$rootdisk::/mnt:-o subvol=/@root"
    "$rootdisk::/mnt/home:-o subvol=/@home"
    "$rootdisk::/mnt/mnt/snapshots:-o subvol=/@snapshots"
    "$rootdisk::/mnt/swap:-o subvol=/@swap"
    "/dev/nvme0n1p1:fat -F 32:/mnt/boot/efi:"
)

die() {
    echo "$@"
    exit 1
}

mnt_vols() {
    for vol in "${volumes[@]}"; do
        IFS=: read -r -a info <<< "$vol"
        [[ -n "${info[1]}" ]] && mkfs.${info[1]} "${info[0]}"
        [[ -n "${info[2]}" ]] && mkdir -p "${info[2]}" && mount ${info[3]} "${info[0]}" "${info[2]}"
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
    btrfs filesystem mkswapfile --size 128g /mnt/@swap/swapfile
    umount -R /mnt

    mnt_vols
    mkdir -p /mnt/etc
    cp -r ./airootfs/etc/modprobe.d /mnt/etc/
    pacstrap /mnt base base-devel linux-lts linux-firmware btrfs-progs
    genfstab -U /mnt | sed -E 's/subvolid=[0-9]+//;s/,,/,/' >> /mnt/etc/fstab
    echo '/swap/swapfile none swap defaults 0 0' >> /mnt/etc/fstab
    cp "${self_dir}/install.sh" /mnt/root/
    arch-chroot /mnt /root/install.sh install
    rm -rf  /mnt/root/install.sh
    umount -R /mnt

    mount $rootdisk /mnt
    "${self_dir}/tools/snapshot" -s init
    umount -R /mnt
}

install() {
    echo $hostname > /etc/hostname
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo -e 'en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8' >> /etc/locale.gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf
    locale-gen

    # kernel
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
    pacman -S --noconfirm polkit sudo zsh git

    useradd -m -s /bin/zsh $user
    usermod -aG wheel $user
    sed -E -i 's/#\s*(%wheel\s+ALL=\(ALL:ALL\)\s+ALL)/\1/' /etc/sudoers
    echo -e "${user_passwd}\n${user_passwd}" | passwd $user
}

[[ -z "$user_passwd" ]] && die "undefine user password"

action="prepare"
(( $# > 0 )) && action="$1"
$action

