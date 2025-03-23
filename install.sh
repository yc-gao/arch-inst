#!/usr/bin/env bash
set -e

self_path="$(realpath $0)"
self_dir="$(dirname ${self_path})"

hostname='ycgao-pc'
user="ycgao"
user_passwd=""

espdisk="/dev/nvme0n1p1"
rootdisk="/dev/nvme0n1p2"
targetfs="/mnt"

volumes=(
    "${rootdisk}:-o subvol=rootfs:${targetfs}"
    "${espdisk}::${targetfs}/boot/efi"
)

die() {
    echo "$@" >&2
    exit 1
}

mnt_vols() {
    local vol
    for vol in "$@"; do
        IFS=: read -r disk mopt mpoint <<< "${vol}"
        if [[ -n "${mpoint}" ]]; then
            mkdir -p "${mpoint}"
            mount ${mopt} "${disk}" "${mpoint}"
        fi
    done
}

do_install() {
    echo "${hostname}" > /etc/hostname
    ln -sfT /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo -e 'en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8' >> /etc/locale.gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf
    locale-gen

    # kernel
    mkinitcpio -P

    # boot
    pacman -S --noconfirm grub efibootmgr
    grub-install --efi-directory=/boot/efi --recheck

    # nvidia
    pacman -S --noconfirm nvidia-lts

    # network
    pacman -S --noconfirm networkmanager
    systemctl enable NetworkManager

    # misc and account
    pacman -S --noconfirm polkit sudo zsh git

    useradd -m -s /bin/zsh "${user}"
    usermod -aG wheel "${user}"
    sed -E -i 's/#\s*(%wheel\s+ALL=\(ALL:ALL\)\s+ALL)/\1/' /etc/sudoers
    echo "${user}:${user_passwd}" | chpasswd

    pacman -S --noconfirm openssh
    systemctl enable sshd
}

prepare() {
    # prepare disk
    mkfs.fat -F32 "${espdisk}"
    mkfs.btrfs -f -L rootdisk "${rootdisk}"

    mount "${rootdisk}" "${targetfs}"

    btrfs subvol create "${targetfs}/swap"
    btrfs filesystem mkswapfile --size 128g "${targetfs}/swap/swapfile"

    mkdir -p "${targetfs}/snapshots"
    btrfs subvol create "${targetfs}/snapshots/main"
    ln -sT snapshots/main "${targetfs}/rootfs"

    umount -R "${targetfs}"

    # install system
    mnt_vols "${volumes[@]}"
    pacstrap "${targetfs}" base base-devel linux-lts linux-firmware \
        btrfs-progs exfatprogs
    cp "${self_path}" ${targetfs}/root/
    arch-chroot "${targetfs}" "/root/$(basename "${self_path}")" do_install
    rm -rf "${targetfs}/root/$(basename "${self_path}")"

    cp -r "${self_dir}/grub" ${targetfs}/boot
    {
        echo -e "UUID=$(lsblk -n -o uuid "${espdisk}")      /boot/efi       vfat    defaults    0    2"
        echo -e "UUID=$(lsblk -n -o uuid "${rootdisk}")     /swap           btrfs   defaults,subvol=swap    0    0"
        echo -e "/swap/swapfile    none    swap    defaults    0    0"
    } > "${targetfs}/etc/fstab"
    umount -R "${targetfs}"
    "${self_dir}/rmanager" snapshot
}

action="prepare"
if (( $# >0 )); then
    action="$1"
fi
"${action}"

