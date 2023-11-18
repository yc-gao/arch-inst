#!/bin/bash
set -e

hostname='xundaoxd-pc'
user="xundaoxd"
user_passwd=""

espdisk="/dev/nvme0n1p1"
rootdisk="/dev/nvme0n1p2"
targetfs="/mnt"

volumes=(
    "$rootdisk::-o subvol=volumes/root:${targetfs}"
    "$rootdisk::-o subvol=volumes:${targetfs}/mnt/volumes"
    "$rootdisk::-o subvol=snapshots:${targetfs}/mnt/snapshots"
    "$espdisk:::${targetfs}/boot/efi"
)

die() {
    echo "$@"
    exit 1
}

# disk:format cmd:mount options:mount point
mnt_vols() {
    local vol
    for vol in "$@"; do
        IFS=: read -r disk fcmd mopt mpoint <<< "$vol"
        [[ -n "${fopt}" ]] && ${fcmd} "${disk}"
        [[ -n "${mpoint}" ]] && mkdir -p "${mpoint}" && mount "${mopt}" "${disk}" "${mpoint}"
    done
}

prepare() {
    # systemctl stop reflector
    # reflector --verbose --country China --protocol http --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

    # prepare disk
    mkfs.fat -F32 $espdisk
    mkfs.btrfs -f -L rootdisk $rootdisk

    mount $rootdisk ${targetfs}
    btrfs subvol create ${targetfs}/volumes
    btrfs filesystem mkswapfile --size 128g ${targetfs}/volumes/swap
    ln -s snapshots/root.latest ${targetfs}/volumes/root

    btrfs subvol create ${targetfs}/snapshots
    ln -s root.init ${targetfs}/snapshots/root.latest
    btrfs subvol create ${targetfs}/snapshots/root.init

    umount -R ${targetfs}
    # prepare disk end

    mnt_vols "${volumes[@]}"
    pacstrap ${targetfs} base base-devel linux-lts linux-firmware btrfs-progs

    cat > ${targetfs}/etc/fstab <<EOF
UUID=$(lsblk -n -o uuid $rootdisk)  /               btrfs   rw,relatime,ssd,space_cache=v2,subvol=volumes/root  0   0
UUID=$(lsblk -n -o uuid $rootdisk)  /mnt/volumes    btrfs   rw,relatime,ssd,space_cache=v2,subvol=volumes       0   0
UUID=$(lsblk -n -o uuid $rootdisk)  /mnt/snapshots  btrfs   rw,relatime,ssd,space_cache=v2,subvol=snapshots     0   0
/mnt/volumes/swap                   none            swap    defaults                                            0   0
UUID=$(lsblk -n -o uuid $espdisk)   /boot/efi       vfat    rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro   0   2
EOF

    cp ./install.sh ${targetfs}/root/
    arch-chroot ${targetfs} /root/install.sh install
    rm -rf  ${targetfs}/root/install.sh

    ./tools/snapshot -p /mnt -s
    umount -R ${targetfs}
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

