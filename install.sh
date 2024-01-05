#!/bin/bash
set -e

hostname='xundaoxd-pc'
user="xundaoxd"
user_passwd=""

espdisk="/dev/nvme0n1p1"
rootdisk="/dev/nvme0n1p2"
targetfs="/mnt"

volumes=(
    "${rootdisk}:-o subvol=volumes/root:${targetfs}"
    "${rootdisk}:-o subvol=volumes/swap:${targetfs}/swap"
    "${espdisk}::${targetfs}/boot/efi"
)

die() {
    echo "$@" >&2
    exit 1
}

# disk:format cmd:mount options:mount point
mnt_vols() {
    local vol
    for vol in "$@"; do
        IFS=: read -r disk mopt mpoint <<< "$vol"
        [[ -n "${mpoint}" ]] && mkdir -p "${mpoint}" && mount ${mopt} "${disk}" "${mpoint}"
    done
}

prepare() {
    # systemctl stop reflector
    # reflector --verbose --country China --protocol http --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

    # prepare disk
    mkfs.fat -F32 $espdisk
    mkfs.btrfs -f -L rootdisk $rootdisk

    mount $rootdisk $targetfs
    btrfs subvol create ${targetfs}/volumes

    btrfs subvol create ${targetfs}/volumes/swap
    btrfs filesystem mkswapfile --size 128g ${targetfs}/volumes/swap/swapfile

    ln -s snapshots/current ${targetfs}/volumes/root
    mkdir -p ${targetfs}/volumes/snapshots
    ln -s root ${targetfs}/volumes/snapshots/current
    btrfs subvol create ${targetfs}/volumes/snapshots/root

    umount -R ${targetfs}
    # prepare disk end

    # install system
    mnt_vols "${volumes[@]}"
    pacstrap ${targetfs} base base-devel linux-lts linux-firmware btrfs-progs
    cp ./install.sh ${targetfs}/root/
    arch-chroot ${targetfs} /root/install.sh install
    rm -rf  ${targetfs}/root/install.sh

    cat > ${targetfs}/etc/fstab <<EOF
UUID=$(lsblk -n -o uuid $espdisk)   /boot/efi       vfat    defaults                                                0   2
UUID=$(lsblk -n -o uuid $rootdisk)  /swap           btrfs   rw,relatime,ssd,space_cache=v2,subvol=volumes/swap      0   0
/swap/swapfile                      none            swap    defaults                                                0   0
EOF
    cp -r ./airootfs/boot ${targetfs}/
    umount -R ${targetfs}
    # end install system

    ./tools/vtils checkout
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

